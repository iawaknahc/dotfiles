" ALE
let g:ale_linters_explicit=1
let g:ale_fix_on_save=1
let g:ale_lint_on_text_changed='never'
let g:ale_linters={
      \ 'go': ['golint', 'govet', 'golangci-lint'],
      \ 'javascript': ['eslint'],
      \ 'javascriptreact': ['eslint'],
      \ 'javascript.jsx': ['eslint'],
      \ 'typescript': ['tslint', 'eslint'],
      \ 'typescriptreact': ['tslint', 'eslint'],
      \ 'typescript.jsx': ['tslint', 'eslint'],
      \ }
let g:ale_fixers={
      \ 'c': ['clang-format'],
      \ 'cpp': ['clang-format'],
      \ 'go': ['gofmt'],
      \ 'javascript': ['prettier'],
      \ 'javascriptreact': ['prettier'],
      \ 'javascript.jsx': ['prettier'],
      \ 'typescript': ['prettier'],
      \ 'typescriptreact': ['prettier'],
      \ 'typescript.tsx': ['prettier'],
      \ 'css': ['prettier'],
      \ 'scss': ['prettier'],
      \ 'python': ['isort', 'black'],
      \ 'ocaml': ['ocamlformat'],
      \ 'dart': ['dartfmt'],
      \ 'sh': ['shfmt'],
      \ }
let g:ale_dart_dartfmt_options = '--fix'
let g:ale_python_black_options = '--fast'

" Activate plugins distributed with VIM
" https://github.com/vim/vim/tree/master/runtime/pack/dist/opt
packadd! matchit

" Declare package
if exists('*packager#init')
  call packager#init()
  " The package manager itself
  call packager#add('kristijanhusak/vim-packager', {'type': 'opt'})
  " Language
  call packager#add('dart-lang/dart-vim-plugin')
  call packager#add('HerringtonDarkholme/yats.vim')
  call packager#add('ocaml/vim-ocaml')
  call packager#add('pangloss/vim-javascript')
  " Lint
  " ALE is optional because sometimes we want to turn it off entirely.
  call packager#add('w0rp/ale', {'type': 'opt'})
  " Fuzzy finder
  call packager#add('junegunn/fzf')
  call packager#add('junegunn/fzf.vim')
  " Colorscheme
  call packager#add('dracula/vim', {'name': 'dracula'})
  " Set indentation automatically
  call packager#add('tpope/vim-sleuth')
  " Show the color of the color code
  " VIM itself is assumed to be running with true color
  call packager#add('chrisbra/Colorizer')
endif

" Enable optional packages
packadd! ale

command! -bang PackUpdate packadd vim-packager | source $MYVIMRC | call packager#update({ 'force_hooks': '<bang>' })
command! PackClean packadd vim-packager | source $MYVIMRC | call packager#clean()
command! PackStatus packadd vim-packager | source $MYVIMRC | call packager#status()

" neovim defaults to filetype plugin indent on
filetype on
filetype plugin on
filetype indent off

" Security
" https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md
set nomodeline

" Code completion
set omnifunc=v:lua.vim.lsp.omnifunc

" Look
set signcolumn=yes
set guicursor=
set number
set laststatus=2
set statusline=
set statusline+=%f%m%r%h%w%=
set statusline+=%-14.(%{&filetype}%)
set statusline+=%-20.(%{&fileencoding}\ %{&fileformat}\ %{&eol?'eol':'noeol'}%)
set statusline+=%-12.(%l:%c%V%)%3P
set list listchars=tab:>-,trail:~
" According to :h xterm-true-color
" t_8f and t_8b are only set when $TERM is xterm*
" In tmux, $TERM is screen by default.
" Therefore, we have to set them explicitly here.
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
syntax on
" Since dracula@2 we need to packadd! it first before we can activate the colorscheme
" See https://github.com/dracula/vim/issues/140
silent! packadd! dracula | colorscheme dracula

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
nnoremap <Leader>b :Buffers<CR>

" Command
command! -nargs=1 Space execute "setlocal tabstop=" . <args> . " shiftwidth=" . <args> . " softtabstop=" . <args> . " expandtab"
command! -nargs=1 Tab   execute "setlocal tabstop=" . <args> . " shiftwidth=" . <args> . " softtabstop=" . <args> . " noexpandtab"

" File type extras
augroup MyFileTypeExtras
  autocmd!
  " By default, filetype.vim treats *.env as sh
  " *.env files will then be ALE-fixed with shfmt on save.
  " But this is sometimes undesired because some envvars may have trailing whitespaces.
  autocmd BufNewFile,BufRead *.env setlocal filetype=
  " Disable auto-wrapping of text and comment
  autocmd FileType * setlocal formatoptions-=c
  autocmd FileType * setlocal formatoptions-=t
  " Enable spellchecking
  autocmd FileType gitcommit,text,markdown setlocal spell spelllang=en_us
augroup END
