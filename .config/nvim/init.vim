" :help nvim-from-vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

set inccommand=nosplit

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
" nvim-treesitter is not very stable
" silent! packadd nvim-treesitter
silent! packadd popup.nvim
silent! packadd plenary.nvim
silent! packadd telescope.nvim
silent! packadd gitsigns.nvim
silent! packadd nvim-compe

" Configure lspconfig
lua <<EOF
local has_telescope, _ = pcall(require, 'telescope')
local on_attach = function(client, bufnr)
  local map_opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-]>', '<Cmd>lua vim.lsp.buf.definition()<CR>', map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', map_opts)
  if (has_telescope) then
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>r', "<Cmd>lua require('telescope.builtin').lsp_references()<CR>", map_opts)
  else
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>r', "<Cmd>lua vim.lsp.buf.references()<CR>", map_opts)
  end
end

local servers = {
  "cssls",
  "html",
  "jsonls",
  "tsserver",
  "gopls",
  "flow",
  -- multiple language server enabled for a buffer will
  -- cause previous messages to be overridden.
  -- https://github.com/neovim/neovim/issues/12105
  --
  -- The above issue was claimed to be resolved.
  -- But I still could not get it working for eslint :(
  -- "efm",
}

local status, lspconfig = pcall(require, 'lspconfig')
if (status) then
  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
      on_attach = on_attach,
    }
  end
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
    enabled = true,
    autocomplete = true,
    source = {
      path = true,
      buffer = true,
      nvim_lsp = true,
      nvim_lua = true,
    },
  }
end
EOF

" Configure telescope
lua <<EOF
local status, telescope = pcall(require, 'telescope')
if (status) then
  local actions = require('telescope.actions')
  telescope.setup {
    defaults = {
      vimgrep_arguments = {
        'rg',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
        '--ignore',
        '--hidden',
        '--color=never',
        -- Explicitly ignore .git because it is a hidden file that is not in .gitignore.
        -- https://github.com/BurntSushi/ripgrep/issues/1509#issuecomment-595942433
        '--glob=!.git/',
      },
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
        },
      },
    },
  }

  local map_opts = { noremap = true }
  vim.api.nvim_set_keymap('n', '<Leader>f', "<Cmd>lua require('telescope.builtin').git_files()<CR>", map_opts)
  vim.api.nvim_set_keymap('n', '<Leader>b', "<Cmd>lua require('telescope.builtin').buffers()<CR>", map_opts)
  vim.api.nvim_set_keymap('n', '<Leader>g', "<Cmd>lua require('telescope.builtin').live_grep()<CR>", map_opts)
end
EOF

augroup MyNeovimAutocommands
  autocmd!
  " https://neovim.io/news/2021/07
  au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}
augroup END
