" ─── Visual ──────────────────────────────────────────────────
set number
set cursorline
syntax on

" ─── Behaviour ─────────────────────────────────────────────
set incsearch
set hlsearch
set expandtab
set shiftwidth=2
set softtabstop=2

" Home/End keys for external keyboards
map  <C-A> <Home>
imap <C-A> <Home>
vmap <C-A> <Home>
map  <C-E> <End>
imap <C-E> <End>
vmap <C-E> <End>

" fzf from Homebrew (works on both Intel and ARM Macs)
if system("brew --prefix fzf 2>/dev/null") != ""
  let $FZF_HOME = substitute(system("brew --prefix fzf"), '\n', '', '')
  execute "set rtp+=" . $FZF_HOME
endif

