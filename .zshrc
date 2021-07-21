# SET ZSH THEME
source ~/.zsh/themes/powerlevel10k/powerlevel10k.zsh-theme

# Load ZSH Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

plugins=(
  git
  dotenv
  docker
  kubectl
)

# Load Brew
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

# ALIAS COMMANDS
alias ls="exa --icons --group-directories-first" 
