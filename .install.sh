#!/bin/bash
#
# .install.sh
# One-shot setup for a fresh macOS / Linux machine.
# macOS-first with Linux (WSL/Ubuntu) support.

set -e

# ─── REPO URLS ────────────────────────────────────────────────────
BREWFILE_URL="https://raw.githubusercontent.com/zenatuz/dotfiles/main/.brewfile"
HELMLIST_URL="https://raw.githubusercontent.com/zenatuz/dotfiles/main/.helmlist"
DOTFILES_REPO="https://github.com/zenatuz/dotfiles.git"

# ─── Helpers ──────────────────────────────────────────────────────
command_exists() { command -v "$1" >/dev/null 2>&1; }
dir_exists() { [[ -d "$1" ]]; }

print_header() {
    echo "========================================"
    echo "  $1"
    echo "========================================"
}

print_subheader() {
    echo "  --- $1 ---"
}

# ─── Step 1: System requirements ──────────────────────────────────
install_ubuntu_packages() {
    print_header "Installing Ubuntu requirements"

    local packages=(
        "apt-transport-https" "build-essential" "curl" "file"
        "git" "procps" "socat" "software-properties-common"
        "wget" "zsh" "unzip"
    )

    local install_required=false
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii\s*$package"; then
            install_required=true
            break
        fi
    done

    if $install_required; then
        sudo apt-get update -qq && \
        sudo apt-get install -y -qq "${packages[@]}"
    else
        echo "  Ubuntu requirements already installed."
    fi
}

install_xcode_tools() {
    print_header "Checking Xcode Command Line Tools"
    if ! xcode-select -p &>/dev/null; then
        echo "  Installing Xcode CLT..."
        xcode-select --install
    else
        echo "  Xcode CLT already installed."
    fi
}

# ─── Step 2: Homebrew ─────────────────────────────────────────────
install_brew() {
    print_header "Installing Homebrew"
    if ! command_exists brew; then
        echo "  Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "  Homebrew already installed."
    fi

    # Ensure brew is in PATH for both macOS ARM and Linux
    if command_exists brew; then
        if [[ "$(uname -m)" == "arm64" ]] && [[ "$OSTYPE" == "darwin"* ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    else
        echo "  ERROR: Brew installation failed."
        exit 1
    fi
}

# ─── Step 3: oh-my-zsh + plugins ──────────────────────────────────
install_oh_my_zsh() {
    print_header "Installing oh-my-zsh and plugins"

    if ! dir_exists "$HOME/.oh-my-zsh"; then
        echo "  Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "  oh-my-zsh already installed."
    fi

    print_subheader "ZSH plugins"

    if ! dir_exists "$HOME/.zsh/plugins/zsh-autosuggestions"; then
        echo "  Installing zsh-autosuggestions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
    else
        echo "  zsh-autosuggestions already installed."
    fi

    if ! dir_exists "$HOME/.zsh/plugins/zsh-syntax-highlighting"; then
        echo "  Installing zsh-syntax-highlighting..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/plugins/zsh-syntax-highlighting
    else
        echo "  zsh-syntax-highlighting already installed."
    fi
}

# ─── Step 4: Powerlevel10k ───────────────────────────────────────
install_powerlevel10k() {
    print_header "Installing Powerlevel10k theme"
    if ! dir_exists "$HOME/.zsh/themes/powerlevel10k"; then
        echo "  Installing..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/themes/powerlevel10k/
    else
        echo "  Powerlevel10k already installed."
    fi
}

# ─── Step 5: Brew packages ────────────────────────────────────────
install_brew_packages() {
    print_header "Installing Brew packages"

    if command_exists brew; then
        local brewfile_path="$HOME/.brewfile"
        if [[ ! -f "$brewfile_path" ]]; then
            echo "  Downloading Brewfile..."
            curl -fsSL -o "$brewfile_path" "$BREWFILE_URL"
        fi
        echo "  Installing packages (this may take a while)..."
        brew bundle install --file="$brewfile_path" --quiet
    else
        echo "  Brew not installed. Skipping."
    fi
}

# ─── Step 6: Helm plugins ─────────────────────────────────────────
install_helm_plugins() {
    print_header "Installing Helm plugins"

    if command_exists helm; then
        local plugins_file="/tmp/helmlist"
        if [[ ! -f "$plugins_file" ]]; then
            curl -fsSL -o "$plugins_file" "$HELMLIST_URL"
        fi

        if [[ -f "$plugins_file" ]]; then
            while IFS= read -r line || [[ -n "$line" ]]; do
                if [[ ! "$line" =~ ^\s*$|^# ]]; then
                    local plugin_name=$(echo "$line" | awk '{print $1}')
                    local plugin_source=$(echo "$line" | awk '{print $2}')

                    if helm plugin list | grep -q "$plugin_name"; then
                        echo "  $plugin_name already installed."
                    else
                        echo "  Installing $plugin_name..."
                        helm plugin install "$plugin_source" >/dev/null 2>&1
                    fi
                fi
            done < "$plugins_file"
        fi

        echo "  Installed plugins:"
        helm plugin list
    else
        echo "  Helm not installed. Skipping."
    fi
}

# ─── Step 7: Create local config files ─────────────────────────────
create_local_configs() {
    if [[ ! -f "$HOME/.gitconfig.local" ]]; then
        echo ""
        echo "  ─── Git local config ───"
        echo "  ~/.gitconfig.local not found. Let's set your identity:"
        read -p "  Name: " git_name
        read -p "  Email: " git_email
        cat > "$HOME/.gitconfig.local" <<-EOF
[user]
    name = $git_name
    email = $git_email
EOF
        echo "  Created ~/.gitconfig.local"
    else
        echo "  ~/.gitconfig.local already exists. Skipping."
    fi
}

# ─── Step 8: Clone dotfiles with yadm ─────────────────────────────
clone_dotfiles() {
    print_header "Setting up dotfiles"

    if command_exists yadm; then
        local yadm_repo="$HOME/.local/share/yadm/repo.git"
        if [ -d "$yadm_repo" ]; then
            echo "  yadm repo already exists. Updating..."
            yadm pull
        else
            echo "  Cloning dotfiles with yadm..."
            yadm clone "$DOTFILES_REPO"
        fi
    else
        echo "  yadm not installed yet. Installing..."
        brew install yadm
        yadm clone "$DOTFILES_REPO"
    fi
}

# ═══════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║       Zenatuz Dotfiles Installer         ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "  OS: Linux"
    install_ubuntu_packages
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  OS: macOS"
    install_xcode_tools
fi

install_brew
install_oh_my_zsh
install_powerlevel10k
install_brew_packages
install_helm_plugins
create_local_configs
clone_dotfiles

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║      Installation complete! 🎉          ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""
echo "  Next steps:"
echo "    1. Restart your terminal or run: source ~/.zshrc"
echo "    2. (macOS) Rancher Desktop will be installed for K8s/Docker"
echo "    3. Run p10k configure to customize your prompt"
echo "    4. Set up local overrides in ~/.zshrc.local (optional)"
echo ""
