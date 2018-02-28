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
Plug 'prabirshrestha/async.vim' | Plug 'prabirshrestha/vim-lsp'
call plug#end()

" LSP
function! s:SetupLSP(filetype)
  execute 'autocmd FileType ' . a:filetype . ' nnoremap <C-]> :LspDefinition<CR>'
  execute 'autocmd FileType ' . a:filetype . ' nnoremap K :LspHover<CR>'
  execute 'autocmd FileType ' . a:filetype . ' setlocal omnifunc=lsp#complete'
endfunction
augroup MyLSP
  autocmd!
  " python
  " pip3 install python-language-server
  if executable('pyls')
    call s:SetupLSP('python')
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'pyls',
          \ 'cmd': { server_info -> ['pyls'] },
          \ 'whitelist': ['python'],
          \ })
  endif
  " golang
  " go get -u github.com/sourcegraph/go-langserver
  if executable('go-langserver')
    call s:SetupLSP('go')
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'go-langserver',
          \ 'cmd': { server_info -> ['go-langserver', '-mode', 'stdio'] },
          \ 'whitelist': ['go'],
          \ })
  endif
  " css
  " yarn global add vscode-css-languageserver-bin
  if executable('css-languageserver')
    call s:SetupLSP('css')
    call s:SetupLSP('scss')
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'css-languageserver',
          \ 'cmd': { server_info -> [&shell, &shellcmdflag, 'css-languageserver --stdio']},
          \ 'whitelist': ['css', 'scss'],
          \ })
  endif
  " typescript
  " yarn global add typescript-language-server
  if executable('typescript-language-server')
    call s:SetupLSP('typescript')
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'typescript-language-server',
          \ 'cmd': { server_info -> [&shell, &shellcmdflag, 'typescript-language-server --stdio']},
          \ 'root_uri': { server_info -> lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
          \ 'whitelist': ['typescript'],
          \ })
  endif
  " flow
  " yarn global add flow-language-server
  if executable('flow-language-server')
    call s:SetupLSP('javascript')
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'flow-language-server',
          \ 'cmd': { server_info -> [&shell, &shellcmdflag, 'flow-language-server --stdio']},
          \ 'root_uri': { server_info -> lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), '.flowconfig'))},
          \ 'whitelist': ['javascript'],
          \ })
  endif
  " ocaml and reasonml
  " yarn global add ocaml-language-server
  if executable('ocaml-language-server')
    call s:SetupLSP('ocaml')
    call s:SetupLSP('reason')
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'ocaml-language-server',
          \ 'cmd': { server_info -> [&shell, &shellcmdflag, 'ocaml-language-server --stdio']},
          \ 'whitelist': ['reason', 'ocaml'],
          \ })
  endif
augroup END

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
