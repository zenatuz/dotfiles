#!/bin/bash
#
# .install.sh
# One-shot setup for a fresh macOS / Linux machine.
# macOS-first with Linux (WSL/Ubuntu) support.

set -e

# Always work from the user's home directory
cd "$HOME"

# ─── REPO URLS ────────────────────────────────────────────────────
# Pass a branch name as first argument to test a branch (e.g. `mac-migration`).
# Pass --skip-backup to skip backing up current dotfiles.
ARGS=()
SKIP_BACKUP=false
for arg in "$@"; do
    if [[ "$arg" == "--skip-backup" ]]; then
        SKIP_BACKUP=true
    else
        ARGS+=("$arg")
    fi
done

BRANCH="${ARGS[0]:-main}"

HELMLIST_URL="https://raw.githubusercontent.com/zenatuz/dotfiles/$BRANCH/.helmlist"
DOTFILES_REPO="https://github.com/zenatuz/dotfiles.git"
DOTFILES_BRANCH="$BRANCH"

# ─── Helpers ──────────────────────────────────────────────────────
command_exists() { command -v "$1" >/dev/null 2>&1; }
dir_exists() { [[ -d "$1" ]]; }

print_header() {
    echo "========================================"
    echo "  $1"
    echo "========================================"
}

# ─── Step 0: Backup existing dotfiles ─────────────────────────────
# Creates ~/dotfiles-backup-<timestamp>/ with a copy of everything
# the installer might touch. Skips if --skip-backup is passed or
# BACKUP_DISABLE=1 is set (useful for repeated runs on a clean VM).
backup_dotfiles() {
    [[ "$1" == "--skip-backup" || "${BACKUP_DISABLE:-0}" == "1" ]] && return 0

    local backup_dir="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    local files_to_backup=(
        ".zshrc" ".zsh" ".config/starship.toml" ".vimrc"
        ".config/ghostty/config" ".gitconfig" ".gitconfig.local" ".gitignore"
        ".editorconfig" ".brewfile" ".p10k.zsh"
    )

    # Check if any of these files/dirs actually exist
    local has_anything=false
    for f in "${files_to_backup[@]}"; do
        [[ -e "$HOME/$f" ]] && { has_anything=true; break; }
    done

    if ! $has_anything; then
        echo "  No existing dotfiles found — nothing to back up."
        return 0
    fi

    echo "  Backing up current dotfiles to: $backup_dir"
    mkdir -p "$backup_dir"

    for f in "${files_to_backup[@]}"; do
        local src="$HOME/$f"
        if [[ -e "$src" ]]; then
            local dest_dir="$backup_dir/$(dirname "$f")"
            mkdir -p "$dest_dir"
            cp -r "$src" "$dest_dir/"
            echo "    ✓ $f"
        fi
    done

    echo "  Backup complete → $backup_dir"
    echo "  Restore with: cp -r $backup_dir/. ~/"
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

    # Source brew shellenv regardless of how brew was installed
    # (needed because freshly-installed brew isn't in PATH yet)
    if [[ "$(uname -m)" == "arm64" ]] && [[ "$OSTYPE" == "darwin"* ]]; then
        local brew_prefix="/opt/homebrew"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        local brew_prefix="/home/linuxbrew/.linuxbrew"
    fi

    if [[ -n "$brew_prefix" ]] && [[ -x "$brew_prefix/bin/brew" ]]; then
        echo "  Sourcing brew environment from $brew_prefix..."
        eval "$("$brew_prefix/bin/brew" shellenv)"
        echo "  brew now at: $(command -v brew 2>/dev/null || echo 'not found')"
    else
        echo "  Brew binary not found at expected paths."
    fi

    if ! command_exists brew; then
        echo "  ERROR: Brew installation failed."
        exit 1
    fi
}

# Ensure git identity is set — needed by yadm pull to stash/merge
ensure_git_identity() {
    local name email
    name="$(git config user.name 2>/dev/null || true)"
    email="$(git config user.email 2>/dev/null || true)"

    if [[ -n "$name" && -n "$email" ]]; then
        return 0
    fi

    # Try to read from ~/.gitconfig.local using git's own parser
    local local_file="$HOME/.gitconfig.local"
    if [[ -f "$local_file" ]]; then
        name="$(git config -f "$local_file" user.name 2>/dev/null || true)"
        email="$(git config -f "$local_file" user.email 2>/dev/null || true)"
    fi

    # Fallback to known defaults if identity is missing or invalid
    local bad_name=false
    if echo "$name" | grep -Eq '^[[:space:]]*$|^[[:space:]]*<'; then
        bad_name=true
    fi
    local bad_email=false
    if echo "$email" | grep -Eq '^[[:space:]]*$|^[[:space:]]*<'; then
        bad_email=true
    fi

    if [[ -z "$name" || -z "$email" || "$bad_name" == true || "$bad_email" == true ]]; then
        name="Renato Batista"
        email="zenatuz@gmail.com"
        # Also write to .gitconfig.local so it persists across yadm rebases
        echo "  Setting git identity: $name <$email>"
        cat > "$local_file" <<-EOF
[user]
    name = $name
    email = $email
EOF
    fi

    # Set globally temporarily so yadm pull / rebase works
    git config --global user.name "$name"
    git config --global user.email "$email"
}

# ─── Step 3: ZSH plugins (zsh-autosuggestions, syntax-highlighting) ─
install_zsh_plugins() {
    print_header "Installing ZSH plugins"

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

# ─── Step 4: Starship prompt ───────────────────────────────────────
install_starship() {
    print_header "Installing Starship prompt"
    if command_exists brew; then
        if ! command_exists starship; then
            echo "  Installing Starship..."
            brew install starship
        else
            echo "  Starship already installed."
        fi
    fi
}

# ─── Step 5: Brew packages ────────────────────────────────────────
install_brew_packages() {
    print_header "Installing Brew packages"

    if command_exists brew; then
        # Pre-install ncurses to avoid parallel lock when eza+tree install simultaneously
        echo "  Pre-installing ncurses (base dependency)..."
        brew install ncurses --quiet 2>/dev/null || true

        local brewfile_path="$HOME/.brewfile"
        if [[ ! -f "$brewfile_path" ]]; then
            echo "  ERROR: $brewfile_path not found. yadm should have provisioned it."
            echo "  Try: brew bundle --file=\"$brewfile_path\" after the install finishes."
            return 1
        fi
        echo "  Installing packages (this may take a while)..."
        # Silence third-party deprecation warnings (e.g. vipinator) that can't be fixed here
        brew bundle install --file="$brewfile_path" --quiet 2>/dev/null || {
            echo "  ⚠️  Some packages failed. Check the output above."
        }
    else
        echo "  Brew not installed. Skipping."
    fi
}

# ─── Step 6: Helm plugins ─────────────────────────────────────────
install_helm_plugins() {
    print_header "Installing Helm plugins"

    if command_exists helm; then
        local plugins_file="/tmp/helmlist"
        curl -fsSL -o "$plugins_file" "$HELMLIST_URL"

        if [[ -f "$plugins_file" ]]; then
            while IFS= read -r line || [[ -n "$line" ]]; do
                # Skip blank lines and comments (POSIX-safe, works on macOS bash 3.x)
                [[ "$line" =~ ^[[:space:]]*$ || "$line" =~ ^[[:space:]]*# ]] && continue

                local plugin_name
                local plugin_source
                plugin_name=$(echo "$line" | awk '{print $1}')
                plugin_source=$(echo "$line" | awk '{print $2}')

                if helm plugin list | grep -q "$plugin_name"; then
                    echo "  $plugin_name already installed."
                else
                    echo "  Installing $plugin_name..."
                    # HELM_BIN is required by some plugins (e.g. helm-secrets install hook)
                    HELM_BIN="$(command -v helm)" helm plugin install "$plugin_source" --verify=false || echo "  ⚠️  Failed to install $plugin_name"
                fi
            done < "$plugins_file"
        fi

        echo ""
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
        echo "  ~/.gitconfig.local not found."
        echo "  Set your identity after install with:"
        echo '    git config --file ~/.gitconfig.local user.name "Your Name"'
        echo '    git config --file ~/.gitconfig.local user.email "your@email.com"'
        echo ""
        # Interactive prompt only works with a real terminal (not curl | bash)
        if [[ -t 0 ]]; then
            read -p "  Name: " git_name
            read -p "  Email: " git_email
            cat > "$HOME/.gitconfig.local" <<-EOF
[user]
    name = $git_name
    email = $git_email
EOF
            echo "  Created ~/.gitconfig.local from your input."
        else
            echo "  (non-interactive mode — create manually after install)"
        fi
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
            yadm clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO"
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

# Step 0: Backup existing dotfiles before making changes
$SKIP_BACKUP && export BACKUP_DISABLE=1
backup_dotfiles

ensure_git_identity
install_brew
install_zsh_plugins
install_starship
install_helm_plugins
create_local_configs
clone_dotfiles
install_brew_packages

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║      Installation complete! 🎉          ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""
echo "  Next steps:"
echo "    1. Restart your terminal or run: source ~/.zshrc"
echo "    2. (macOS) Colima + Docker provides local containers (replaces Docker Desktop)"
echo "    3. Customize prompt by editing ~/.config/starship.toml"
echo "    4. Set up local overrides in ~/.zshrc.local (optional)"
echo ""
