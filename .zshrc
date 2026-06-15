# ─── Oh My Zsh ─────────────────────────────────────────────────────
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

# Disable error message: Insecure completion-dependent directories detected
ZSH_DISABLE_COMPFIX=true

# ─── Powerlevel10k ─────────────────────────────────────────────────
# Enable instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# SET ZSH THEME
source ~/.zsh/themes/powerlevel10k/powerlevel10k.zsh-theme

# Load p10k theme settings
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ─── ZSH Plugins ───────────────────────────────────────────────────
test -f ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  && source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
test -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  && source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
test -f ~/.zsh/plugins/git.plugin.zsh \
  && source ~/.zsh/plugins/git.plugin.zsh

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# ─── Auto-completions ──────────────────────────────────────────────
[[ ! -f ~/.kubecm ]] || source ~/.kubecm
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ─── WSL2 Interop Fix ──────────────────────────────────────────────
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

# ─── History ────────────────────────────────────────────────────────
SAVEHIST=10000  # Save 10k lines in history file
HISTFILE=~/.zsh_history

# ─── Aliases & Functions ──────────────────────────────────────────
test -f ~/.zsh/zsh-custom.sh && source ~/.zsh/zsh-custom.sh

# ─── SSH Agent ─────────────────────────────────────────────────────
# Share ssh keys with remote container on VS Code
if [ -z "$SSH_AUTH_SOCK" ]; then
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        ssh-agent -s &> $HOME/.ssh/ssh-agent
   fi
   eval `cat $HOME/.ssh/ssh-agent` > /dev/null
fi

# ─── Key Bindings ──────────────────────────────────────────────────
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# ─── PATH ──────────────────────────────────────────────────────────
export PATH=$PATH:~/bin

# Set Default Platform for Docker
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# ─── Brew (macOS ARM / Linux) ──────────────────────────────────────
test -d /opt/homebrew && eval "$(/opt/homebrew/bin/brew shellenv)"
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ─── Krew (kubectl plugins) ───────────────────────────────────────
test -d ${HOME}/.krew/bin && export PATH="${PATH}:${HOME}/.krew/bin"

# ─── kube-ps1 (K8s context in prompt) ─────────────────────────────
test -f /opt/homebrew/opt/kube-ps1/share/kube-ps1.sh \
  && source /opt/homebrew/opt/kube-ps1/share/kube-ps1.sh

# ─── Mcfly (shell history) ─────────────────────────────────────────
if command -v mcfly &> /dev/null; then
  eval "$(mcfly init zsh)"
fi

# ─── Zoxide (smarter cd) ───────────────────────────────────────────
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# ─── MySQL Client (if installed via brew) ─────────────────────────
test -d /opt/homebrew/opt/mysql-client/ \
  && export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# ─── Orbstack (Docker Desktop alternative) ─────────────────────────
test -d ~/.orbstack/bin && export PATH="$HOME/.orbstack/bin:$PATH"

# ─── Local overrides (machine-specific, not tracked by yadm) ──────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ─── Finalize p10k ─────────────────────────────────────────────────
(( ! ${+functions[p10k]} )) || p10k finalize
