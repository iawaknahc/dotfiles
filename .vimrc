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
set guicursor=
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
set list listchars=tab:>-,trail:~
" Highlight textwidth+1
set colorcolumn=+1
if !has('nvim')
  " According to :h xterm-true-color
  " t_8f and t_8b are only set when $TERM is xterm*
  " In tmux, $TERM is screen by default.
  " Therefore, we have to set them explicitly here.
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
set termguicolors
silent! colorscheme dracula

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
