
call plug#begin('~/.vim/plugged')
" colorscheme
Plug 'altercation/vim-colors-solarized'

Plug 'tpope/vim-repeat'

" editing
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'

" fuzzy search
Plug 'junegunn/fzf', { 'do': './install --bin' }
Plug 'junegunn/fzf.vim'

" git integration
Plug 'airblade/vim-gitgutter'

" languages
Plug 'pangloss/vim-javascript' | Plug 'mxw/vim-jsx'
call plug#end()

let g:gitgutter_sign_column_always=1
let g:jsx_ext_required=0

set clipboard+=unnamedplus
set number ruler showcmd colorcolumn=80
set hidden
set scrolloff=10
set ignorecase smartcase
set ttimeout ttimeoutlen=100
set updatetime=250 " suggested by vim-gitgutter
set shiftwidth=2 softtabstop=2 expandtab
set background=dark
colorscheme solarized

autocmd FileType vim
  \ setlocal shiftwidth=2 softtabstop=2 expandtab colorcolumn=80
autocmd FileType python
  \ setlocal shiftwidth=4 softtabstop=4 expandtab colorcolumn=79
autocmd FileType javascript
  \ setlocal shiftwidth=2 softtabstop=2 expandtab colorcolumn=80
autocmd FileType sh
  \ setlocal shiftwidth=2 softtabstop=2 expandtab colorcolumn=80
