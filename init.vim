set rtp+=/usr/local/opt/fzf

call plug#begin('~/.vim/plugged')
" colorscheme
Plug 'altercation/vim-colors-solarized'

" fuzzy search
Plug 'junegunn/fzf.vim'

" git integration
Plug 'airblade/vim-gitgutter'

" languages
Plug 'pangloss/vim-javascript' | Plug 'mxw/vim-jsx'
call plug#end()

let g:gitgutter_sign_column_always=1
let g:jsx_ext_required=0

set autoindent
set autoread
set background=dark
set backspace=indent,eol,start
set clipboard=unnamed,unnamedplus
set display=lastline
set encoding=utf-8
set hidden
set history=10000
set ignorecase smartcase
set incsearch
set laststatus=2
set mouse=a
set number ruler showcmd colorcolumn=80
set scrolloff=10
set shiftwidth=2 softtabstop=2 expandtab
set smarttab
set ttimeout ttimeoutlen=100
set updatetime=250 " suggested by vim-gitgutter
colorscheme solarized

autocmd FileType vim
  \ setlocal shiftwidth=2 softtabstop=2 expandtab colorcolumn=80
autocmd FileType python
  \ setlocal shiftwidth=4 softtabstop=4 expandtab colorcolumn=79
autocmd FileType javascript
  \ setlocal shiftwidth=2 softtabstop=2 expandtab colorcolumn=80
autocmd FileType sh
  \ setlocal shiftwidth=2 softtabstop=2 expandtab colorcolumn=80
