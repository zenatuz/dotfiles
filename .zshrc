# Enable auto-update for Oh My Zsh
zstyle ':omz:update' mode auto

# This will check for updates every 7 days
zstyle ':omz:update' frequency 7

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# SET ZSH THEME
########################################################################################################################
source ~/.zsh/themes/powerlevel10k/powerlevel10k.zsh-theme

# Load p10k theme settings
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load ZSH Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/.gita-completion.zsh

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  dotenv
  docker
  kubectl
)
########################################################################################################################

# Disable error message: Insecure completion-dependent directories detected
# https://pascalnaber.wordpress.com/2019/10/05/have-a-great-looking-terminal-and-a-more-effective-shell-with-oh-my-zsh-on-wsl-2-using-windows/
ZSH_DISABLE_COMPFIX=true

# FIX WSL2 INTEROP
##################
# https://github.com/microsoft/WSL/issues/5065

fix_wsl2_interop() {
    for i in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
        if [[ -e "/run/WSL/${i}_interop" ]]; then
            export WSL_INTEROP=/run/WSL/${i}_interop
        fi
    done
}

# History file
########################################################################################################################
SAVEHIST=1000  # Save most-recent 1000 lines
HISTFILE=~/.zsh_history

# ALIASES COMMANDS
########################################################################################################################
# Alias: Show aliases
alias aliases="grep -i alias ~/.zshrc"
# Alias: Use exa to show icons when ls
alias ls="exa --icons --group-directories-first"
# Alias: Short for 'ls -l'
alias ll="ls -l"
# Alias: Short for 'ls -la'
alias la="ls -la"
# Alias: Export variables on .env files on current directory
alias setdotenv="export $(grep -v '^#' `pwd`/.env | xargs)"
# Alias: Fix corrupted history file
alias fixhistory="cd ~;mv .zsh_history .zsh_history_bad;strings -eS .zsh_history_bad > .zsh_history;fc -R .zsh_history" 
# Alias: Short for update repositories
alias update="brew update > /dev/null"
# Alias: Short for upgrade system packages
alias upgrade="sudo apt-get upgrade -y -qq && brew upgrade"
# Alias: CD Alviere code directory
alias acode="cd ~/code/mezu/repos"
########################################################################################################################

# DOCKER ALIASES AND FUNCTIONS
##################################

docker_clean_containers (){
  docker container stop $(docker container ls -aq)
  docker container rm $(docker container ls -aq)
}

docker_clean_images (){
  docker image prune -a
}

# KUBERNETES ALIASES AND FUNCTIONS
##################################

clean_jobs () {
    echo "deleting Error pods"
    kubectl get pods | awk 'IF $3 == "Error" { print $1}' | while read pod
    do
            echo $pod
            kubectl delete pod $pod
    done
    echo "deleting ContainerCannotRun pods"
    kubectl get pods | awk 'IF $3 == "ContainerCannotRun" { print $1}' | while read pod
    do
            echo $pod
            kubectl delete pod $pod
    done
    echo "deleting incomplete jobs older then 1h"
    kubectl get jobs | awk 'IF $2 == "0/1"  && $4 ~ /h|d/ {print $1}' | while read job
    do
            echo $job
            kubectl delete job $job
    done
    echo "deleting complete jobs older then 1d"
    kubectl get jobs | awk 'IF $2 == "1/1"  && $4 ~ /d/ {print $1}' | while read job
    do
            echo $job
            kubectl delete job $job
    done
}

########################################################################################################################

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
########################################################################################################################

# Bind Keys - Mac
# https://medium.com/@elhayefrat/how-to-fix-the-home-and-end-buttons-for-an-external-keyboard-in-mac-4da773a0d3a2

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# PATH
export PATH=$PATH:~/bin

# Set Defaul Platform for Docker
DOCKER_DEFAULT_PLATFORM=linux/amd64

# Loading Brew
##############
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
test -d /opt/homebrew && eval "$(/opt/homebrew/bin/brew shellenv)"

########################################################################################################################

# Loading Mcfly
eval "$(mcfly init zsh)"

# Startup commands
yadm pull > /dev/null

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[[ ! -f ~/.kubecm ]] || source ~/.kubecm
