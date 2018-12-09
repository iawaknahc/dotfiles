" ALE
let g:ale_fix_on_save=1
let g:ale_lint_on_text_changed='never'
" dartanalyzer is too slow
let g:ale_linters={
      \ 'dart': [],
      \ }
let g:ale_fixers={
      \ 'go': ['gofmt'],
      \ 'javascript': ['prettier'],
      \ 'typescript': ['prettier'],
      \ 'css': ['prettier'],
      \ 'scss': ['prettier'],
      \ 'python': ['isort'],
      \ 'ocaml': ['ocamlformat'],
      \ 'dart': ['dartfmt'],
      \ }
if executable("flutter")
  let s:flutter_dart_sdk_root = fnamemodify(system('command -v flutter'), ':h') . '/cache/dart-sdk/bin'
  let g:ale_dart_dartfmt_executable = s:flutter_dart_sdk_root . '/dartfmt'
  let g:ale_dart_dartfmt_options = '--fix'
endif

" Activate plugins in other locations
set runtimepath+=/usr/local/opt/fzf

" Activate plugins distributed with vim
" https://github.com/vim/vim/tree/master/runtime/pack/dist/opt
packadd! matchit

" Declare plugins
if exists('*minpac#init')
  call minpac#init()
  call minpac#add('k-takata/minpac', {'type': 'opt'})
  call minpac#add('w0rp/ale', {'type': 'opt'})
  call minpac#add('dart-lang/dart-vim-plugin', {'type': 'opt'})
  call minpac#add('junegunn/fzf.vim')
  call minpac#add('iawaknahc/vim-colorscheme-simple')
  call minpac#add('iawaknahc/vim-synindent')
endif
packadd! ale
packadd! dart-vim-plugin
command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update()
command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()

filetype plugin indent on
syntax enable

" Look
set laststatus=2 number ruler
set list listchars=tab:>-,trail:~
silent! colorscheme simple

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
  autocmd BufRead,BufNewFile dune*,jbuild* set filetype=clojure
  autocmd FileType gitcommit,text,markdown setlocal spell spelllang=en_us
augroup END
