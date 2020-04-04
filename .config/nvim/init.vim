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
nvim_lsp.jsonls.setup({})
nvim_lsp.tsserver.setup({})
nvim_lsp.gopls.setup({})
nvim_lsp.flow.setup({})
EOF

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
