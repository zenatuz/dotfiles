# Enable auto-update for Oh My Zsh
zstyle ':omz:update' mode auto

# This will check for updates every 7 days
zstyle ':omz:update' frequency 7

# Compinstall - Shell completion
zstyle :compinstall filename '~/.zshrc'
autoload -Uz compinit
compinit

autoload bashcompinit
bashcompinit

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# SET ZSH THEME
source ~/.zsh/themes/powerlevel10k/powerlevel10k.zsh-theme

# Load p10k theme settings
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load ZSH Plugins
test -f ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh &&  source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
test -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh && source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
test -f ~/.zsh/plugins/git.plugin.zsh && source ~/.zsh/plugins/git.plugin.zsh

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Load ZSH Auto-completion

# Load other stuff
[[ ! -f ~/.kubecm ]] || source ~/.kubecm
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Disable error message: Insecure completion-dependent directories detected
# https://pascalnaber.wordpress.com/2019/10/05/have-a-great-looking-terminal-and-a-more-effective-shell-with-oh-my-zsh-on-wsl-2-using-windows/
ZSH_DISABLE_COMPFIX=true

# FIX WSL2 INTEROP
# https://github.com/microsoft/WSL/issues/5065

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    fix_wsl2_interop() {
        for i in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
            if [[ -e "/run/WSL/${i}_interop" ]]; then
                export WSL_INTEROP=/run/WSL/${i}_interop
            fi
        done
    }
fi

# History file
SAVEHIST=10000  # Save 10k lines in history file
HISTFILE=~/.zsh_history

# Aliases and Functions
test -f  ~/.zsh/zsh-custom.sh && source ~/.zsh/zsh-custom.sh

# Starting ssh-agent to share ssh keys with remote container on VSCODE » https://code.visualstudio.com/docs/remote/containers#_using-ssh-keys

if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check for a currently running instance of the agent
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> $HOME/.ssh/ssh-agent
   fi
   eval `cat $HOME/.ssh/ssh-agent` > /dev/null
fi
# To verify the key inside the remote container or host, type: ssh-add -l

# Bind Keys - Mac
# https://medium.com/@elhayefrat/how-to-fix-the-home-and-end-buttons-for-an-external-keyboard-in-mac-4da773a0d3a2

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# PATH
export PATH=$PATH:~/bin

# Set Defaul Platform for Docker
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Loading Brew
##############
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
test -d /opt/homebrew && eval "$(/opt/homebrew/bin/brew shellenv)"

# Loading Krew
test -d ${HOME}/.krew/bin && export PATH="${PATH}:${HOME}/.krew/bin"

# Loading kube-ps1
# source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
# PS1='$(kube_ps1)'$PS1

test -f /opt/homebrew/opt/kube-ps1/share/kube-ps1.sh && source /opt/homebrew/opt/kube-ps1/share/kube-ps1.sh

# Loading Alviere utils
test -d ~/code/mezu/repos/ops/utils && export PATH="${PATH}:${HOME}/code/mezu/repos/ops/utils"
test -d ~/code/mezu/repos/docker/generic-builder/bin && export PATH="${PATH}:${HOME}/code/mezu/repos/docker/generic-builder/bin"
test -d /opt/homebrew/opt/mysql-client/bin && export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"e

# Loading Personal utils
test -d ~/code/mezu/repos/renato.batista/utils && export PATH="${PATH}:${HOME}/code/mezu/repos/renato.batista/utils"

# Loading Mcfly
eval "$(mcfly init zsh)"

# Startup commands
# yadm pull > /dev/null

test -d /opt/homebrew/opt/mysql-client/ && export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# Load NetskopeCA if available

test -f "/Library/Application\ Support/Netskope/STAgent/data/netskope-cert-bundle.pem" && \
    export REQUESTS_CA_BUNDLE=/Library/Application\ Support/Netskope/STAgent/data/netskope-cert-bundle.pem &&\
    export CURL_CA_BUNDLE=/Library/Application\ Support/Netskope/STAgent/data/netskope-cert-bundle.pem &&\
    export SSL_CERT_FILE=/Library/Application\ Support/Netskope/STAgent/data/netskope-cert-bundle.pem &&\
    export GIT_SSL_CAPATH=/Library/Application\ Support/Netskope/STAgent/data/netskope-cert-bundle.pem &&\
    export AWS_CA_BUNDLE=/Library/Application\ Support/Netskope/STAgent/data/netskope-cert-bundle.pem

(( ! ${+functions[p10k]} )) || p10k finalize

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/renato.batista/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# kubeswitch
INSTALLATION_PATH=$(brew --prefix switch) && source $INSTALLATION_PATH/switch.sh

# Unset context for current session
# nohup switch -u 2>&1 > /dev/null