#!/bin/bash

echo "Instaling requirements..."
sudo apt-get update && sudo apt-get install -y git openssh-server software-properties-common apt-transport-https build-essential procps file curl wget zsh

# If you want to install vscode on ubuntu uncomment the following
# wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
# sudo apt install code

echo ''
echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

chsh -s $(which zsh)

echo ''
echo "Installing oh-my-zsh plugins"
# echo "Instaling oh-my-zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

# echo "Configuring oh-my-zsh theme, setting Agnoster Theme..."
# sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/g' ~/.zshrc

# echo "Setting RPROMPT to show date and time"
# echo "# https://superuser.com/questions/943844/add-timestamp-to-oh-my-zsh-robbyrussell-theme/943916" >> ~/.zshrc
# echo 'RPROMPT="%{$fg[yellow]%}[%D{%f/%m/%y}|%@]"' >> ~/.zshrc
# echo '' >> ~/.zshrc

# Instaling homebrew
echo ''
echo "Instaling homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install yadm