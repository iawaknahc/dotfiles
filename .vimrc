" ALE
let g:ale_fix_on_save=1
let g:ale_fixers={}
let g:ale_fixers['go']=['gofmt', 'goimports']
let g:ale_fixers['javascript']=['prettier']
let g:ale_fixers['typescript']=['prettier']
let g:ale_fixers['css']=['prettier']
let g:ale_fixers['scss']=['prettier']
let g:ale_lint_on_text_changed='never'

" Activate plugins in other locations
set runtimepath+=/usr/local/opt/fzf
silent! execute 'set runtimepath+='
      \ . substitute(system('opam config var share'),'\n$','','''')
      \ . '/merlin/vim'

" Activate plugins distributed with vim
packadd! matchit
packadd! justify

" Declare plugins
if exists('*minpac#init')
  call minpac#init()
  call minpac#add('k-takata/minpac', {'type': 'opt'})
  call minpac#add('w0rp/ale', {'type': 'opt'})
  call minpac#add('junegunn/fzf.vim')
  call minpac#add('pangloss/vim-javascript')
  call minpac#add('mxw/vim-jsx')
  call minpac#add('leafgarland/typescript-vim')
  call minpac#add('reasonml-editor/vim-reason-plus')
  call minpac#add('iawaknahc/vim-colorscheme-simple')
  call minpac#add('iawaknahc/vim-synindent')
  call minpac#add('prabirshrestha/async.vim')
  call minpac#add('prabirshrestha/vim-lsp')
  call minpac#add('iawaknahc/vim-lsp-defaults')
endif
packadd! ale
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
        \ gitcommit,text,markdown
        \ setlocal spell spelllang=en_us
augroup END
