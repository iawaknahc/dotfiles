set rtp+=/usr/local/opt/fzf

call plug#begin('~/.vim/plugged')
" colorscheme
Plug 'joshdick/onedark.vim'

" fuzzy search
Plug 'junegunn/fzf.vim'

" git integration
Plug 'airblade/vim-gitgutter'

" languages
Plug 'pangloss/vim-javascript' | Plug 'mxw/vim-jsx'
call plug#end()

let g:gitgutter_sign_column_always=1
let g:jsx_ext_required=0

" look
set colorcolumn=80
set number
set ruler
set showcmd
set wildmenu
set laststatus=2
set cursorline
" set termguicolors " assume running on a terminal with true color support
set background=dark
syntax on
colorscheme onedark

" editing
set autoindent
set autoread
set backspace=indent,eol,start
set encoding=utf-8
set hidden
set history=10000
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab
set scrolloff=10
set ttimeout
set ttimeoutlen=100

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

autocmd FileType vim
  \ setlocal shiftwidth=2 softtabstop=2 expandtab colorcolumn=80
autocmd FileType python
  \ setlocal shiftwidth=4 softtabstop=4 expandtab colorcolumn=79
autocmd FileType javascript
  \ setlocal shiftwidth=2 softtabstop=2 expandtab colorcolumn=80
autocmd FileType sh
  \ setlocal shiftwidth=2 softtabstop=2 expandtab colorcolumn=80
