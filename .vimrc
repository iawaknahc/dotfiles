" make syntax/sh.vim need not to guess shell script type
let g:is_posix=1

" ALE
let g:ale_fix_on_save=1
let g:ale_fixers={}
let g:ale_fixers['go']=['gofmt', 'goimports']
let g:ale_fixers['javascript']=['prettier']
let g:ale_fixers['typescript']=['prettier']
let g:ale_javascript_prettier_use_local_config=1
let g:ale_lint_on_text_changed='never'

" Activate plugins in other locations
set runtimepath+=/usr/local/opt/fzf
silent! execute 'set runtimepath+='
      \ . substitute(system('opam config var share'),'\n$','','''')
      \ . '/merlin/vim'

" Activate plugins distributed with vim
packadd matchit
packadd justify

" Declare plugins
if exists('*minpac#init')
  call minpac#init()
  call minpac#add('k-takata/minpac', {'type': 'opt'})
  call minpac#add('junegunn/fzf.vim')
  call minpac#add('w0rp/ale')
  call minpac#add('leafgarland/typescript-vim')
  call minpac#add('reasonml-editor/vim-reason-plus')
  call minpac#add('iawaknahc/vim-colorscheme-simple')
  call minpac#add('prabirshrestha/async.vim')
  call minpac#add('prabirshrestha/vim-lsp')
  call minpac#add('iawaknahc/vim-lsp-defaults')
endif
command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update()
command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()

filetype plugin indent on
syntax enable

" look
set laststatus=2
set list listchars=tab:>-,trail:~
set number
set ruler
silent! colorscheme simple

" command completion
set wildmenu wildmode=longest:full,full

" responsiveness
set lazyredraw

" editing
set autoread
set autoindent
set backspace=indent,eol,start
" force vim not to rename when saving a file
" since renaming may break some file watching programs e.g. webpack
set backupcopy=yes
set hidden
set noswapfile
set scrolloff=5
set nofoldenable

" Make escape sequence timeout faster
" e.g. <Esc>O (Return to normal mode and then press O)
set timeout ttimeout timeoutlen=3000 ttimeoutlen=100

" indentation
set expandtab shiftwidth=2 softtabstop=2

" clipboard
set clipboard+=unnamed

" mouse
set mouse=a

" search
set ignorecase smartcase
set incsearch

" mapping
let mapleader=' '
nnoremap Y y$
nnoremap <Space> <Nop>
nnoremap <Leader><Space> :set hlsearch!<CR>
nnoremap <Leader>b :Buffers<CR>

" commands
command! -nargs=1 Spaces execute "setlocal tabstop=" . <args> . " shiftwidth=" . <args> . " softtabstop=" . <args> . " expandtab"
command! -nargs=1 Tabs   execute "setlocal tabstop=" . <args> . " shiftwidth=" . <args> . " softtabstop=" . <args> . " noexpandtab"

" file type extras
augroup MyFileTypeExtras
  autocmd!
  autocmd FileType
        \ go
        \ setlocal noexpandtab shiftwidth=4 tabstop=4
  autocmd FileType
        \ java
        \ setlocal expandtab shiftwidth=4 softtabstop=4
  autocmd FileType
        \ gitcommit,text,markdown
        \ setlocal spell spelllang=en_us
augroup END
