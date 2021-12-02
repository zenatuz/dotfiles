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
source ~/.zsh/themes/powerlevel10k/powerlevel10k.zsh-theme

# Load ZSH Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  dotenv
  docker
  kubectl
)

# Disable error message: Insecure completion-dependent directories detected
# https://pascalnaber.wordpress.com/2019/10/05/have-a-great-looking-terminal-and-a-more-effective-shell-with-oh-my-zsh-on-wsl-2-using-windows/
ZSH_DISABLE_COMPFIX=true

# Loading Brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# FIX WSL2 INTEROP
# https://github.com/microsoft/WSL/issues/5065
#
fix_wsl2_interop() {
    for i in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
        if [[ -e "/run/WSL/${i}_interop" ]]; then
            export WSL_INTEROP=/run/WSL/${i}_interop
        fi
    done
}

# History
SAVEHIST=1000  # Save most-recent 1000 lines
HISTFILE=~/.zsh_history

# ALIAS COMMANDS
alias ls="exa --icons --group-directories-first" 
alias ll="ls -l"
alias la="ls -la"
alias setdotenv="export $(grep -v '^#' `pwd`/.env | xargs)"
alias fixhistory="cd ~;mv .zsh_history .zsh_history_bad;strings -eS .zsh_history_bad > .zsh_history;fc -R .zsh_history"
alias update="sudo apt-get update -qq && brew update > /dev/null"
alias upgrade="sudo apt-get upgrade -y -qq && brew upgrade"

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

# PATH
export PATH=$PATH:~/bin

# Startup commands
yadm pull > /dev/null

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
