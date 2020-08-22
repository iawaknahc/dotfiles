" :help nvim-from-vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

set inccommand=nosplit

if has('nvim-0.5.0')
  if exists('*packager#init')
    " The plugin installed here must be opt
    " so vanilla vim will not load them.
    call packager#add('neovim/nvim-lsp', {'type': 'opt'})
    call packager#add('nvim-treesitter/nvim-treesitter', {'type': 'opt'})
  endif

  silent! packadd nvim-lsp
  silent! packadd nvim-treesitter

lua <<EOF
local status, nvim_lsp = pcall(require, 'nvim_lsp')
if (status) then
  nvim_lsp.cssls.setup({})
  nvim_lsp.html.setup({})
  nvim_lsp.jsonls.setup({
    cmd = {"json-languageserver", "--stdio"},
  })
  nvim_lsp.tsserver.setup({})
  nvim_lsp.gopls.setup({})
  nvim_lsp.flow.setup({})
  -- multiple language server enabled for a buffer will cause
  -- previous messages to be overridden.
  -- https://github.com/neovim/neovim/issues/12105
  -- nvim_lsp.efm.setup({})
end
EOF

lua <<EOF
local status, nvim_ts = pcall(require, 'nvim-treesitter.configs')
if (status) then
  nvim_ts.setup {
    ensure_installed = {
      'c',
      'lua',
      'go',
      'javascript',
      'typescript',
      'bash',
      'python',
      'markdown',
      'html',
      'css',
    },
    highlight = {
      enable = true,
    },
  }
end
EOF

endif
