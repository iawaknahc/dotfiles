" :help nvim-from-vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

set inccommand=nosplit

if has('nvim-0.5.0')
  if exists('*packager#init')
    call packager#add('neovim/nvim-lsp')
  endif

  packadd nvim-lsp

  if exists('g:nvim_lsp')

lua <<EOF
local nvim_lsp = require'nvim_lsp'
nvim_lsp.cssls.setup({})
nvim_lsp.html.setup({})
nvim_lsp.jsonls.setup({
  cmd = {"json-languageserver", "--stdio"},
})
nvim_lsp.tsserver.setup({})
nvim_lsp.gopls.setup({})
nvim_lsp.flow.setup({})
EOF

  " nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
  nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
  nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
  " nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
  " nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
  " nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
  " nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
  " nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
  " nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

  augroup MyLSP
    autocmd!
    autocmd FileType css,scss,less setlocal omnifunc=v:lua.vim.lsp.omnifunc
    autocmd FileType html setlocal omnifunc=v:lua.vim.lsp.omnifunc
    autocmd FileType json setlocal omnifunc=v:lua.vim.lsp.omnifunc
    autocmd FileType go setlocal omnifunc=v:lua.vim.lsp.omnifunc
    autocmd FileType javascript,javascriptreact,javascript.jsx,typescript,typescriptreact,typescript.tsx setlocal omnifunc=v:lua.vim.lsp.omnifunc
  augroup END

  endif
endif
