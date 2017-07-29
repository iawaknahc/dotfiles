call plug#begin('~/.vim/plugged')
" elixir
Plug 'elixir-lang/vim-elixir'

" fuzzy search
if isdirectory('/usr/local/opt/fzf')
  Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
endif

" git integration
Plug 'airblade/vim-gitgutter'
call plug#end()

let g:gitgutter_sign_column_always=1

" look
set colorcolumn=80
set number
set ruler
set showcmd
set wildmenu
set laststatus=2
set cursorline
set background=dark
set list listchars=tab:>-,trail:.
syntax enable
colorscheme desert

" editing
set autoindent
set autoread
set backspace=indent,eol,start
set encoding=utf-8
set hidden
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab
set scrolloff=10
set ttimeout
set ttimeoutlen=100
set noswapfile
set backupcopy=yes

" clipboard
set clipboard=unnamed,unnamedplus

" search
set ignorecase
set smartcase
set incsearch
set hlsearch

" mouse
set mouse=a

set updatetime=250 " suggested by vim-gitgutter

let mapleader = "\<Space>"
nnoremap <Leader><Leader> :set hlsearch!<CR>
nnoremap <Leader>f :Files<CR>
nnoremap <Leader>b :Buffers<CR>

" file types
autocmd BufRead,BufNewFile BUCK set filetype=python

autocmd FileType vim
  \ setlocal shiftwidth=2 softtabstop=2 expandtab colorcolumn=80

autocmd FileType python
  \ setlocal shiftwidth=4 softtabstop=4 expandtab colorcolumn=79

autocmd FileType javascript
  \ setlocal shiftwidth=2 softtabstop=2 expandtab colorcolumn=80

autocmd FileType sh
  \ setlocal shiftwidth=2 softtabstop=2 expandtab colorcolumn=80

autocmd FileType go
  \ setlocal shiftwidth=4 tabstop=4 noexpandtab colorcolumn=80
