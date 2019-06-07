" ALE
let g:ale_fix_on_save=1
let g:ale_lint_on_text_changed='never'
" dartanalyzer is too slow so we only enable dart_language_server
let g:ale_linters={
      \ 'go': ['gofmt', 'golint', 'govet', 'golangci-lint', 'gopls'],
      \ 'dart': ['language_server'],
      \ 'typescript': ['tsserver', 'tslint', 'eslint'],
      \ }
let g:ale_fixers={
      \ 'c': ['clang-format'],
      \ 'cpp': ['clang-format'],
      \ 'go': ['gofmt'],
      \ 'javascript': ['prettier'],
      \ 'typescript': ['prettier'],
      \ 'css': ['prettier'],
      \ 'scss': ['prettier'],
      \ 'python': ['isort', 'black'],
      \ 'ocaml': ['ocamlformat'],
      \ 'dart': ['dartfmt'],
      \ 'sh': ['shfmt'],
      \ }
let g:ale_dart_dartfmt_options = '--fix'
let g:ale_python_black_options = '--fast'
let g:ale_cpp_clang_options = '-std=c++17 -Wall -Wextra -Wpedantic'
let g:ale_cpp_gcc_options = g:ale_cpp_clang_options
let g:ale_go_golangci_lint_options = '--fast'

" Activate plugins distributed with vim
" https://github.com/vim/vim/tree/master/runtime/pack/dist/opt
packadd! matchit

" Declare plugins
if exists('*packager#init')
  call packager#init()
  call packager#add('kristijanhusak/vim-packager', {'type': 'opt'})
  call packager#add('w0rp/ale')
  call packager#add('dart-lang/dart-vim-plugin')
  call packager#add('soywod/typescript.vim')
  call packager#add('rgrinberg/vim-ocaml')
  call packager#add('junegunn/fzf')
  call packager#add('junegunn/fzf.vim')
  call packager#add('tpope/vim-sleuth')
  call packager#add('dracula/vim', {'name': 'dracula'})
  call packager#add('chrisbra/Colorizer')
endif

command! -bang PackUpdate packadd vim-packager | source $MYVIMRC | call packager#update({ 'force_hooks': '<bang>' })
command! PackClean packadd vim-packager | source $MYVIMRC | call packager#clean()
command! PackStatus packadd vim-packager | source $MYVIMRC | call packager#status()

filetype on
filetype plugin on

" Security
" https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md
set nomodeline

" Look
set laststatus=2 number ruler
set list listchars=tab:>-,trail:~
" According to :h xterm-true-color
" t_8f and t_8b are only set when $TERM is xterm*
" In tmux, $TERM is screen by default.
" Therefore, we have to set them explicitly here.
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
syntax on
" Since dracula@2
" we need to packadd! it first
" before we can activate the colorscheme
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
" Force vim not to rename when saving a file
" since renaming may break some file watching programs e.g. webpack
set backupcopy=yes
set hidden
set noswapfile
set scrolloff=5
set nofoldenable
set clipboard+=unnamed
set mouse=a
" Make escape sequence timeout faster
" e.g. <Esc>O (Return to normal mode and then press O)
set timeout ttimeout timeoutlen=3000 ttimeoutlen=100
" Tell vim to respect the eol convention of the file.
" If we want to add eol, :set endofline and :w
" If we want to remove eol, :set noendofline and :w
" It is particularly useful when we have to deal with
" Kubernetes secret file.
" If the secret file has eol, then when it is used as
" environment variable, the newline character will
" appear at the end, which is almost unexpected.
set nofixendofline
set omnifunc=ale#completion#OmniFunc

" Search
set ignorecase smartcase
set incsearch

" Mapping
let mapleader=' '
nnoremap Y y$
nnoremap <Space> <Nop>
nnoremap <Leader><Space> :set hlsearch!<CR>
nnoremap <Leader>b :Buffers<CR>

" Command
command! -nargs=1 Space execute "setlocal tabstop=" . <args> . " shiftwidth=" . <args> . " softtabstop=" . <args> . " expandtab"
command! -nargs=1 Tab   execute "setlocal tabstop=" . <args> . " shiftwidth=" . <args> . " softtabstop=" . <args> . " noexpandtab"

" File type extras
augroup MyFileTypeExtras
  autocmd!
  autocmd FileType gitcommit,text,markdown setlocal spell spelllang=en_us
augroup END
