" :help nvim-from-vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

set inccommand=nosplit

if has('nvim-0.5.0')

  if exists('*packager#init')
    " The plugin installed here must be opt
    " so vanilla vim will not load them.
    call packager#add('neovim/nvim-lspconfig', {'type': 'opt'})
    call packager#add('nvim-treesitter/nvim-treesitter', {'type': 'opt'})
    call packager#add('nvim-lua/popup.nvim', {'type': 'opt'})
    call packager#add('nvim-lua/plenary.nvim', {'type': 'opt'})
    call packager#add('nvim-telescope/telescope.nvim', {'type': 'opt'})
    call packager#add('lewis6991/gitsigns.nvim', {'type': 'opt'})
    call packager#add('hrsh7th/nvim-compe', {'type': 'opt'})
  endif

  silent! packadd nvim-lspconfig
  silent! packadd nvim-treesitter
  silent! packadd popup.nvim
  silent! packadd plenary.nvim
  silent! packadd telescope.nvim
  silent! packadd gitsigns.nvim
  silent! packadd nvim-compe

" Configure lspconfig
lua <<EOF
local status, lspconfig = pcall(require, 'lspconfig')
if (status) then
  lspconfig.cssls.setup({})
  lspconfig.html.setup({})
  lspconfig.jsonls.setup({})
  lspconfig.tsserver.setup({})
  lspconfig.gopls.setup({})
  lspconfig.flow.setup({})
  -- multiple language server enabled for a buffer will
  -- cause previous messages to be overridden.
  -- https://github.com/neovim/neovim/issues/12105
  --
  -- The above issue was claimed to be resolved.
  -- But I still could not get it working for eslint :(
  -- lspconfig.efm.setup({})
end
EOF

" Configure nvim-treesitter
lua <<EOF
local status, nvim_ts = pcall(require, 'nvim-treesitter.configs')
if (status) then
  nvim_ts.setup {
    ensure_installed = 'maintained',
    highlight = { enable = true },
  }
end
EOF

" Configure gitsigns
lua <<EOF
local status, gitsigns = pcall(require, 'gitsigns')
if (status) then
  gitsigns.setup()
end
EOF

" Configure nvim-compe
lua <<EOF
local status, compe = pcall(require, 'compe')
if (status) then
  vim.o.completeopt = "menuone,noselect"
  compe.setup {
    enabled = true;
    autocomplete = true;
    source = {
      path = true;
      buffer = true;
      nvim_lsp = true;
      nvim_lua = true;
    };
  }
end
EOF

endif

augroup MyNeovimAutocommands
  autocmd!
  " https://neovim.io/news/2021/07
  au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}
augroup END
