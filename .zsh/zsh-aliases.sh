# ALIASES COMMANDS
###################################################

# Alias: Show aliases
alias aliases="cat ~/.zsh/zsh-aliases.sh"

# Alias: Show Functions
alias functions="grep '()' ~/.zsh/zsh-functions.sh"

# Alias: Use exa to show icons when ls
alias ls="exa --icons --group-directories-first"

# Alias: Short for 'ls -l'
alias ll="ls -l"

# Alias: Short for 'ls -la'
alias la="ls -la"

# Alias: Export variables on .env files on current directory
# alias setdotenv="if [ -f .env ]; then;export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst);fi"

# Alias: Fix corrupted history file
alias fixhistory="cd ~;mv .zsh_history .zsh_history_bad;strings -eS .zsh_history_bad > .zsh_history;fc -R .zsh_history" 

# Alias: Short for update repositories
alias update="brew update > /dev/null"

# Alias: Use Nvim as default text-editor
alias vi="nvim"
alias vim="nvim"

# Alias: Httpie default parameters
alias http="http --follow --all"

# Alias: kubectl
alias k="kubectl"

# Alias: kubectx
alias kctx="kubectx"

# Alias: k9s
alias k9s="k9s -A"

# Alias: docker
alias d-up="docker-compose up --remove-orphans"
