unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

call plug#begin('~/.vim/plugged')

" languages
Plug 'elixir-lang/vim-elixir'

" colorscheme
Plug 'dracula/vim'

" fuzzy search
if isdirectory('/usr/local/opt/fzf')
  Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
endif

call plug#end()

" look
set number
set laststatus=2
set list listchars=tab:>-,trail:.
set termguicolors
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
colorscheme dracula

" responsiveness
set nocursorline
set nocursorcolumn
set lazyredraw
set synmaxcol=120

" editing
set autoindent
set autoread
set encoding=utf-8
set hidden
set smarttab
set noswapfile
set backupcopy=yes

" clipboard
set clipboard=unnamed,unnamedplus

" search
set ignorecase
set smartcase
set hlsearch

let mapleader="\<Space>"
nnoremap <Leader><Leader> :set hlsearch!<CR>
nnoremap <Leader>f :Files<CR>
nnoremap <Leader>b :Buffers<CR>

" file types
autocmd BufRead,BufNewFile BUCK set filetype=python
autocmd BufRead,BufNewFile Podfile,*.podspec set filetype=ruby

" indentation
autocmd FileType go setlocal noexpandtab shiftwidth=4 tabstop=4
autocmd FileType javascript,json,ruby,sh setlocal expandtab shiftwidth=2 softtabstop=2
