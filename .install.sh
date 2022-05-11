#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Instaling Ubuntu requirements and ZSH ...PLEASE WAIT!!!"
    
    sudo apt-get update -qq && \
    sudo apt-get install -y -qq \
      apt-transport-https \
      build-essential \
      curl \
      file \
      git \
      openssh-server \
      procps \
      socat \
      software-properties-common \
      wget \
      zsh;
      
      if [[ "$SHELL" != *"zsh" ]]; then 
        echo "Current Shell: $SHELL"
        echo "Defining default shell to zsh"
        chsh -s $(which zsh);
      fi
fi

# Installing oh-my-zsh
echo ""
echo "Installing oh-my-zsh"
echo 
#############################################
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# "Instaling oh-my-zsh plugins..."
echo ""
echo "Installing oh-my-zsh plugins"
echo 
#############################################
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
curl https://raw.githubusercontent.com/nosarthur/gita/master/.gita-completion.zsh --output ~/.zsh/.gita-completion.zsh --silent

# Instaling oh-my-zsh powerlevel10k theme
echo ""
echo "Instaling oh-my-zsh powerlevel10k theme"
echo 
#############################################
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/themes/powerlevel10k/

# Instaling homebrew
echo ""
echo "Instaling homebrew"
echo 
#############################################
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo ""
echo "Loading Brew"
echo 
#############################################
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew -v

echo ""
echo "Instaling additional packages with brew"
echo 
#############################################

brew tap cantino/mcfly

brew install \
  ansible \
  aws-iam-authenticator \
  aws-vault \
  awscli \
  azure-cli \
  exa \
  fzf \
  helm \
  helmfile \
  httpie \
  jq \
  k9s \
  kubecm \
  kubectx \
  kubernetes-cli \
  mcfly \
  ncurses \
  packer \
  tldr \
  warrensbox/tap/tfswitch \
  yadm

# Firacode Nerd font
brew tap caskroom/fonts
brew cask install font-firacode-nerd-font
brew cask install font-firacode-nerd-font-mono

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Installing additional brew packages for Mac"
  brew install 1password-cli
fi

echo ""
echo "Instaling Helm plugins"
echo 
#############################

helm plugin install https://github.com/databus23/helm-diff

echo ""
echo "Cloning Dotenv project to ~/"
echo 

# Removing temp files
rm -rf ~/.zshrc ~/.p10k.zsh

# Cloning dotfiles
cd ~
yadm clone git@github.com:zenatuz/dotfiles.git

sudo -k

echo "Instalation process is now complete!"
exit 0