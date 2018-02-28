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

" plugins installed with vim-plug
call plug#begin('~/.vim/plugged')
if isdirectory('/usr/local/opt/fzf')
  Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
endif
Plug 'leafgarland/typescript-vim'
Plug 'reasonml-editor/vim-reason-plus'
if executable('opam') && executable('ocamlmerlin')
  Plug (substitute(system('opam config var share'),'\n$','','''') . '/merlin/vim')
endif
Plug 'iawaknahc/vim-colorscheme-simple'
Plug 'w0rp/ale'
call plug#end()

" plugins distributed with vim
packadd matchit
packadd justify

" look
set laststatus=2
set list listchars=tab:>-,trail:.
set number
set ruler
silent! colorscheme simple

" command completion
set wildmenu
set wildmode=longest:full,full

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

" indentation
set expandtab shiftwidth=2 softtabstop=2

" clipboard
set clipboard+=unnamed

" mouse
set mouse=a

" search
set hlsearch
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

" additional file types
augroup MyAdditionFileType
  autocmd!
  autocmd BufRead,BufNewFile jbuild setlocal filetype=lisp
  autocmd BufRead,BufNewFile BUCK setlocal filetype=python
  autocmd BufRead,BufNewFile Podfile,*.podspec setlocal filetype=ruby
  autocmd BufRead,BufNewFile *.gradle setlocal filetype=groovy
augroup END

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
