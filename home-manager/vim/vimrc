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
set foldcolumn=1
set signcolumn=yes
" The default is 4.
set numberwidth=1
set number
set showcmd
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
" lead:. is taken from the help of neovim.
" trail:- is the default of neovim.
" nbsp:+ is the default of neovim.
" tab:>  is the default of neovim. We change it to tab:>_ so that
" the space is visible and distinguishable from leading spaces.
set list listchars=leadmultispace:▏.,lead:.,tab:▏_,trail:-,nbsp:+
set breakindent

set termguicolors
colorscheme slate
syntax on

" Completion
set completeopt=menu,menuone,noselect
" Show at most 10 items only
set pumheight=10

" Command mode
" shell by default is $SHELL.
" But I do not want neovim to run command with fish.
set shell=sh
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
" This controls how often the swapfile is written.
" This also controls how often vim-gitgutter updates the signs.
" :h updatetime
set updatetime=100
set scrolloff=5
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

" Fold
set foldmethod=indent
set foldlevelstart=99

" Search
" Turn on hlsearch initially so that the results are highlighted by default.
set hlsearch
set ignorecase smartcase
set incsearch
set nowrapscan

" Mapping
" Y is the same as yy by default. But Y being y$ is more useful.
nnoremap Y y$
" Disable :h <Space>
nnoremap <Space> <Nop>
" neovim :h CTRL-L-default with nohlsearch changed to hlsearch!
nnoremap <C-l> <Cmd>set hlsearch!<Bar>diffupdate<Bar>normal! <C-L><CR>
" Make n always search forward
nnoremap <expr> n 'Nn'[v:searchforward]
xnoremap <expr> n 'Nn'[v:searchforward]
onoremap <expr> n 'Nn'[v:searchforward]
" Make N always search backward
nnoremap <expr> N 'nN'[v:searchforward]
xnoremap <expr> N 'nN'[v:searchforward]
onoremap <expr> N 'nN'[v:searchforward]

" Command
command! -nargs=1 Space execute "setlocal tabstop=" . <args> . " shiftwidth=" . <args> . " softtabstop=" . <args> . " expandtab"
command! -nargs=1 Tab   execute "setlocal tabstop=" . <args> . " shiftwidth=" . <args> . " softtabstop=" . <args> . " noexpandtab"

augroup MyVimAutocommands
  autocmd!
  " By default, filetype.vim treats *.env as sh
  " We do NOT want to run any before-save fix on *.env
  " For example, some envvars may have trailing whitespaces we do want to preserve.
  autocmd BufNewFile,BufRead *.env setlocal filetype=
  " Enable spellchecking
  autocmd FileType gitcommit,text,markdown setlocal spell spelllang=en_us
augroup END
