# rtk — Shell Aliases
# Source this file in ~/.zshrc to transparently wrap common commands.
# Tool-agnostic: works with any LLM client (opencode, Copilot, Claude Code, etc.)
#
# Usage:
#   source configs/rtk.aliases.zsh
#   echo 'source /path/to/configs/rtk.aliases.zsh' >> ~/.zshrc

# Files
alias ls='rtk ls'
alias cat='rtk read'
alias find='rtk find'

# Git
alias git='rtk git'
alias gs='rtk git status'
alias gl='rtk git log'
alias gd='rtk git diff'
alias ga='rtk git add'
alias gc='rtk git commit'
alias gp='rtk git push'
alias gpl='rtk git pull'

# Search
alias grep='rtk grep'
alias rg='rtk grep'

# Tests
alias pytest='rtk pytest'
alias cargo-test='rtk cargo test'
alias jest='rtk jest'

# Build
alias cargo-build='rtk cargo build'
alias cargo-clippy='rtk cargo clippy'

# Containers
alias docker-ps='rtk docker ps'
alias docker-logs='rtk docker logs'
alias kubectl-pods='rtk kubectl pods'
alias kubectl-logs='rtk kubectl logs'

# Raw fallback: prefix with \ to bypass rtk (e.g. \ls, \git status)
