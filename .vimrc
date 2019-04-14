" ALE
let g:ale_fix_on_save=1
let g:ale_lint_on_text_changed='never'
" dartanalyzer is too slow so we only enable dart_language_server
let g:ale_linters={
      \ 'dart': ['language_server'],
      \ 'typescript': ['tsserver', 'tslint', 'eslint'],
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
let g:ale_dart_dartfmt_options = '--fix'

" Activate plugins distributed with vim
" https://github.com/vim/vim/tree/master/runtime/pack/dist/opt
packadd! matchit

" Declare plugins
if exists('*packager#init')
  call packager#init()
  call packager#add('kristijanhusak/vim-packager', {'type': 'opt'})
  call packager#add('w0rp/ale', {'type': 'opt'})
  call packager#add('dart-lang/dart-vim-plugin', {'type': 'opt'})
  call packager#add('soywod/typescript.vim', {'type': 'opt'})
  call packager#add('rgrinberg/vim-ocaml', {'type': 'opt'})
  call packager#add('junegunn/fzf')
  call packager#add('junegunn/fzf.vim')
  call packager#add('tpope/vim-sleuth')
endif

silent! packadd! ale
silent! packadd! dart-vim-plugin
silent! packadd! typescript.vim
silent! packadd! vim-ocaml

command! -bang PackUpdate packadd vim-packager | source $MYVIMRC | call packager#update({ 'force_hooks': '<bang>' })
command! PackClean packadd vim-packager | source $MYVIMRC | call packager#clean()
command! PackStatus packadd vim-packager | source $MYVIMRC | call packager#status()

filetype on
filetype plugin on

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
  autocmd FileType gitcommit,text,markdown setlocal spell spelllang=en_us
augroup END
