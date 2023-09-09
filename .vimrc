" Activate plugins distributed with VIM
" https://github.com/vim/vim/tree/master/runtime/pack/dist/opt
packadd! matchit

" neovim defaults to filetype plugin indent on
filetype on
filetype plugin on
filetype indent off

" Security
" https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md
set nomodeline

" Look
set signcolumn=yes
set number
set laststatus=2
let g:statusline_fileformat = {
  \ 'dos': 'CRLF',
  \ 'unix': 'LF',
  \ 'mac': 'CR',
  \ }
set statusline=
set statusline+=%f%m%r%h%w
set statusline+=%=%{&filetype}\ %{&fileencoding}\ %{g:statusline_fileformat[&fileformat]}\ %{&eol?'eol':'noeol'}
" 99999:99999 is more than enough.
set statusline+=%=%5l:%-5c\ %3p%%
set list listchars=tab:>-,lead:.,trail:~,nbsp:+
" Highlight textwidth+1
set colorcolumn=+1

" https://sw.kovidgoyal.net/kitty/faq/#using-a-color-theme-with-a-background-color-does-not-work-well-in-vim
if !has('nvim')
  set mouse=a
  set ttymouse=sgr
  set balloonevalterm
  " Styled and colored underline support
  let &t_AU = "\e[58:5:%dm"
  let &t_8u = "\e[58:2:%lu:%lu:%lum"
  let &t_Us = "\e[4:2m"
  let &t_Cs = "\e[4:3m"
  let &t_ds = "\e[4:4m"
  let &t_Ds = "\e[4:5m"
  let &t_Ce = "\e[4:0m"
  " Strikethrough
  let &t_Ts = "\e[9m"
  let &t_Te = "\e[29m"
  " Truecolor support
  let &t_8f = "\e[38:2:%lu:%lu:%lum"
  let &t_8b = "\e[48:2:%lu:%lu:%lum"
  let &t_RF = "\e]10;?\e\\"
  let &t_RB = "\e]11;?\e\\"
  " Bracketed paste
  let &t_BE = "\e[?2004h"
  let &t_BD = "\e[?2004l"
  let &t_PS = "\e[200~"
  let &t_PE = "\e[201~"
  " Cursor control
  let &t_RC = "\e[?12$p"
  let &t_SH = "\e[%d q"
  let &t_RS = "\eP$q q\e\\"
  let &t_SI = "\e[5 q"
  let &t_SR = "\e[3 q"
  let &t_EI = "\e[1 q"
  let &t_VS = "\e[?12l"
  " Focus tracking
  let &t_fe = "\e[?1004h"
  let &t_fd = "\e[?1004l"
  execute "set <FocusGained>=\<Esc>[I"
  execute "set <FocusLost>=\<Esc>[O"
  " Window title
  let &t_ST = "\e[22;2t"
  let &t_RT = "\e[23;2t"

  " vim hardcodes background color erase even if the terminfo file does
  " not contain bce. This causes incorrect background rendering when
  " using a color theme with a background color in terminals such as
  " kitty that do not support background color erase.
  let &t_ut=''
endif
set termguicolors

" Completion
set completeopt=menu,menuone,noselect

" Command completion
set wildmenu wildmode=longest:full,full

" Responsiveness
set lazyredraw

" Editing
set autoread
set autoindent
set backspace=indent,eol,start
" Directly write to file when saving
set nobackup nowritebackup
set hidden
set noswapfile
set scrolloff=5
set nofoldenable
set clipboard+=unnamed
set mouse=a
" Make escape sequence timeout faster
" e.g. <Esc>O (Return to normal mode and then press O)
set timeout ttimeout timeoutlen=3000 ttimeoutlen=100
" Tell VIM to respect the EOL convention of the file.
" If we want to add EOL, :set endofline and :w
" If we want to remove EOL, :set noendofline and :w
" It is particularly useful when we have to deal with Kubernetes secret file.
" If the secret file has EOL and is used as environment variable,
" the newline character will appear at the end, which is almost unexpected.
" However, lsp requires fixendofline to remove extra lines at the end of file.
" Therefore, this option should be set on buffer with lsp.
" See https://github.com/neovim/neovim/blob/e41e8b3fda42308b4c77fb0e52a9719ef4d543d8/runtime/lua/vim/lsp/util.lua#L478
set nofixendofline

" Search
set ignorecase smartcase
set incsearch

" Mapping
let mapleader=' '
" Y is the same as yy by default. But Y being y$ is more useful.
nnoremap Y y$
" Disable Ex mode
nnoremap Q <Nop>
nnoremap <Space> <Nop>
nnoremap <Leader><Space> :set hlsearch!<CR>

" Command
command! -nargs=1 Space execute "setlocal tabstop=" . <args> . " shiftwidth=" . <args> . " softtabstop=" . <args> . " expandtab"
command! -nargs=1 Tab   execute "setlocal tabstop=" . <args> . " shiftwidth=" . <args> . " softtabstop=" . <args> . " noexpandtab"

augroup MyVimAutocommands
  autocmd!
  " By default, filetype.vim treats *.env as sh
  " We do NOT want to run any before-save fix on *.env
  " For example, some envvars may have trailing whitespaces we do want to preserve.
  autocmd BufNewFile,BufRead *.env setlocal filetype=
  " Disable auto-wrapping of text and comment
  autocmd FileType * setlocal formatoptions-=c
  autocmd FileType * setlocal formatoptions-=t
  " Enable spellchecking
  autocmd FileType gitcommit,text,markdown setlocal spell spelllang=en_us
augroup END
