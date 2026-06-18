# ═══════════════════════════════════════════════════════════════════
# Zsh Configuration — Starship Prompt
# ═══════════════════════════════════════════════════════════════════

# ─── Completions ─────────────────────────────────────────────────
autoload -Uz compinit
compinit

autoload bashcompinit
bashcompinit

# ─── Azure CLI Completion ────────────────────────────────────────
test -f /opt/homebrew/share/zsh/site-functions/_az && source /opt/homebrew/share/zsh/site-functions/_az

# ─── kubectl Completion ──────────────────────────────────────────
if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
fi

# ─── Starship Prompt ──────────────────────────────────────────────
eval "$(starship init zsh)"

# ─── Suppress PROMPT_SP (the stray % on partial lines) ────────────
unsetopt PROMPT_SP

# ─── Transient Prompt (replace with ❯ after Enter) ────────────────
function _starship_transient_prompt() {
  print -n '\r\e[K'
  print -Pn '%B%F{green}❯%f%b '
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _starship_transient_prompt

# ─── Window Title (show current dir) ──────────────────────────────
function set_win_title() { echo -ne "\033]0; ${PWD/#$HOME/~} \007" }
precmd_functions+=(set_win_title)

# ─── ZSH Plugins ─────────────────────────────────────────────────
test -f ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  && source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
test -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  && source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ─── fzf (key bindings + completions) ─────────────────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ─── History ──────────────────────────────────────────────────────
SAVEHIST=10000
HISTFILE=~/.zsh_history

# ─── Aliases & Functions ─────────────────────────────────────────
test -f ~/.zsh/zsh-custom.sh && source ~/.zsh/zsh-custom.sh

# ─── SSH Agent ───────────────────────────────────────────────────
# macOS handles ssh-agent via keychain automatically.
# This only starts it for Linux/WSL where it's not managed.
if [[ "$OSTYPE" != "darwin"* ]] && [ -z "$SSH_AUTH_SOCK" ]; then
  ssh-agent -s &> $HOME/.ssh/ssh-agent
  eval "$(cat $HOME/.ssh/ssh-agent)" > /dev/null
fi

# ─── Key Bindings ────────────────────────────────────────────────
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# ─── PATH ────────────────────────────────────────────────────────
export PATH=$PATH:~/bin

# ─── Brew (macOS ARM / Linux) ────────────────────────────────────
test -d /opt/homebrew && eval "$(/opt/homebrew/bin/brew shellenv)"
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ─── Krew (kubectl plugins) ─────────────────────────────────────
test -d ${HOME}/.krew/bin && export PATH="${PATH}:${HOME}/.krew/bin"

# ─── Mcfly (shell history) ───────────────────────────────────────
if command -v mcfly &> /dev/null; then
  eval "$(mcfly init zsh)"
fi

# ─── Zoxide (smarter cd) ─────────────────────────────────────────
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# ─── MySQL Client ────────────────────────────────────────────────
test -d /opt/homebrew/opt/mysql-client/ \
  && export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# ─── Rancher Desktop ─────────────────────────────────────────────
test -d ~/.rd/bin && export PATH="$HOME/.rd/bin:$PATH"

# ─── Local overrides (machine-specific, not tracked) ────────────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
