#!/bin/bash

brewfile_url="https://raw.githubusercontent.com/zenatuz/dotfiles/main/.brewfile"
helmlist_url="https://raw.githubusercontent.com/zenatuz/dotfiles/main/.helmlist"

# Function to check if a directory exists
directory_exists() {
    [[ -d "$1" ]]
}

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print a section header
print_header() {
    echo "========================================"
    echo "$1"
    echo "========================================"
}

# Function to print a sub-section header
print_subheader() {
    echo "--- $1 ---"
}

# Function to install packages on Ubuntu
install_ubuntu_packages() {
    print_header "Installing Ubuntu requirements and ZSH"
    
    # List of packages to be installed
    local packages=("apt-transport-https" "build-essential" "curl" "file" "git" "procps" "socat" "software-properties-common" "wget" "zsh")
    
    # Initialize flag to track if any package needs to be installed
    local install_required=false

    # Check if each package is installed, and set install_required flag if not installed
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii\s*$package"; then
            install_required=true
            break
        fi
    done
    
    # Install packages if required, otherwise print a message
    if $install_required; then
        sudo apt-get update -qq && \
        sudo apt-get install -y -qq "${packages[@]}"
    else
        echo "Ubuntu requirements and ZSH are already installed."
    fi
}




# Function to install Xcode Command Line Tools on macOS
install_xcode_tools() {
    print_header "Installing Xcode Command Line Tools"
    xcode-select --install
}

# Function to install Homebrew on both Linux and macOS
install_brew() {
    print_header "Checking and Installing Homebrew"
    if ! command_exists brew; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi

    # Ensure Brew environment is loaded
    if command_exists brew; then
        echo "Loading Brew environment..."
        local brew_path
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew_path="/usr/local/bin"
        else
            brew_path="$(brew --prefix)/bin"
        fi

        if ! grep -qF "$brew_path" ~/.bashrc; then
            echo "eval \"\$($brew_path/brew shellenv)\"" >> ~/.bashrc
            eval "$(brew shellenv)"
        fi
    else
        echo "Brew installation failed."
        exit 1
    fi
}

# Function to install oh-my-zsh and plugins
install_oh_my_zsh() {
    print_header "Checking and Installing oh-my-zsh and Plugins"
    if ! directory_exists "$HOME/.oh-my-zsh"; then
        echo "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "oh-my-zsh is already installed."
    fi

    print_subheader "Installing oh-my-zsh plugins and auto-completions"
    if ! directory_exists "$HOME/.zsh/plugins/zsh-autosuggestions"; then
        echo "Installing zsh-autosuggestions plugin..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
    else
        echo "zsh-autosuggestions plugin is already installed."
    fi

    if ! directory_exists "$HOME/.zsh/plugins/zsh-syntax-highlighting"; then
        echo "Installing zsh-syntax-highlighting plugin..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/plugins/zsh-syntax-highlighting
    else
        echo "zsh-syntax-highlighting plugin is already installed."
    fi

    if ! directory_exists "$HOME/.zsh/plugins/git.plugin.zsh"; then
        echo "Installing git.plugin.zsh plugin..."
        curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh --output ~/.zsh/plugins/git.plugin.zsh --silent
    else
        echo "git.plugin.zsh plugin is already installed."
    fi
}

# Function to install powerlevel10k theme
install_powerlevel10k() {
    print_header "Installing oh-my-zsh powerlevel10k theme"
    if ! directory_exists "$HOME/.zsh/themes/powerlevel10k"; then
        echo "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/themes/powerlevel10k/
    else
        echo "Powerlevel10k theme is already installed."
    fi
}

# Function to install additional packages with brew
install_brew_packages() {
    print_header "Installing additional packages with Brew"
    if command_exists brew; then
        # Check if the Brewfile exists locally, otherwise download it
        local brewfile_path=~/dotfiles/.brewfile
        if [[ ! -f "$brewfile_path" ]]; then
            echo "Brewfile not found locally. Downloading from URL..."
            curl -fsSL -o "$brewfile_path" $brewfile_url
        fi
        brew bundle install --file="$brewfile_path" --quiet
    else
        echo "Brew is not installed. Skipping brew packages installation."
    fi
}

# Function to install Helm plugins
install_helm_plugins() {
    print_header "Installing Helm plugins from list file"
    if command_exists helm; then
        local plugins_file="helmlist"
        
        # Check if the local file exists, otherwise download it from the URL
        if [[ ! -f "$plugins_file" ]]; then
            local plugins_url="$helmlist_url"
            echo "Helm plugins list file not found locally. Downloading from $plugins_url..."
            curl -fsSL -o "$plugins_file" "$plugins_url"
        fi
        
        if [[ -f "$plugins_file" ]]; then
            while IFS= read -r line || [[ -n "$line" ]]; do
                # Skip empty lines and comments
                if [[ ! "$line" =~ ^\s*$|^# ]]; then
                    local plugin_name=$(echo "$line" | awk '{print $1}')
                    local plugin_source=$(echo "$line" | awk '{print $2}')
                    
                    # Check if the plugin is already installed
                    if helm plugin list | grep -q "$plugin_name"; then
                        echo "$plugin_name plugin is already installed."
                    else
                        # Install the plugin silently
                        helm plugin install "$plugin_source" >/dev/null 2>&1
                    fi
                fi
            done < "$plugins_file"
        else
            echo "Failed to download Helm plugins list file."
        fi
        
        # List installed plugins
        echo "Installed Helm plugins:"
        helm plugin list
    else
        echo "Helm is not installed. Skipping Helm plugins installation."
    fi
}


# Function to clone dotfiles repo with YADM
clone_dotfiles() {
    print_header "Cloning dotfiles repo with YADM"
    if ! command_exists yadm; then
        echo "YADM is not installed. Please install YADM manually."
        exit 1
    fi

    yadm clone https://github.com/zenatuz/dotfiles.git
}

# Main script

# Determine OS and run appropriate functions
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_ubuntu_packages
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_xcode_tools
fi

install_brew
install_oh_my_zsh
install_powerlevel10k
install_brew_packages
install_helm_plugins
clone_dotfiles

echo "========================================"
echo "Installation process is now complete!"
echo "========================================"
exit 0
