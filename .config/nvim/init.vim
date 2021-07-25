" :help nvim-from-vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

set inccommand=nosplit

if exists('*packager#init')
  " The plugin installed here must be opt
  " so vanilla vim will not load them.
  call packager#add('neovim/nvim-lspconfig', {'type': 'opt'})
  call packager#add('nvim-treesitter/nvim-treesitter', {'type': 'opt', 'branch': '0.5-compat'})
  call packager#add('nvim-lua/popup.nvim', {'type': 'opt'})
  call packager#add('nvim-lua/plenary.nvim', {'type': 'opt'})
  call packager#add('nvim-telescope/telescope.nvim', {'type': 'opt'})
  call packager#add('lewis6991/gitsigns.nvim', {'type': 'opt'})
  call packager#add('hrsh7th/nvim-compe', {'type': 'opt'})
  call packager#add('lukas-reineke/indent-blankline.nvim', {'type': 'opt'})
  call packager#add('norcalli/nvim-colorizer.lua', {'type': 'opt'})
endif

silent! packadd nvim-lspconfig
silent! packadd nvim-treesitter
silent! packadd popup.nvim
silent! packadd plenary.nvim
silent! packadd telescope.nvim
silent! packadd gitsigns.nvim
silent! packadd nvim-compe
" indent-blankline does not work with listchars :(
" https://github.com/lukas-reineke/indent-blankline.nvim/issues/74
" silent! packadd indent-blankline.nvim
silent! packadd nvim-colorizer.lua

" Configure lspconfig
lua <<EOF
-- on_attach sets up things that are common to all LSP servers.
local on_attach = function(client, bufnr)
  local has_telescope, _ = pcall(require, 'telescope')
  local map_opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-]>', '<Cmd>lua vim.lsp.buf.definition()<CR>', map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', map_opts)
  if (has_telescope) then
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>r', "<Cmd>lua require('telescope.builtin').lsp_references()<CR>", map_opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>d', "<Cmd>lua require('telescope.builtin').lsp_document_diagnostics()<CR>", map_opts)
  else
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>r', "<Cmd>lua vim.lsp.buf.references()<CR>", map_opts)
  end
  vim.api.nvim_command[[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
end

local status, lspconfig = pcall(require, 'lspconfig')
if (status) then
  local configs = require'lspconfig/configs'
  if not lspconfig.efm_javascript then
    configs.efm_javascript = {
      default_config = {
        cmd = {
          'efm-langserver',
          '-c',
          lspconfig.util.path.join(vim.loop.os_homedir(), '.config/efm-langserver/javascript.yaml'),
        },
        root_dir = function(fname)
          return lspconfig.util.root_pattern('package.json')(fname)
        end,
        filetypes = {
          'javascript',
          'javascriptreact',
          'javascript.jsx',
          'typescript',
          'typescriptreact',
          'typescript.tsx',
        },
      }
    }
  end

  if not lspconfig.efm_go then
    configs.efm_go = {
      default_config = {
        cmd = {
          'efm-langserver',
          '-c',
          lspconfig.util.path.join(vim.loop.os_homedir(), '.config/efm-langserver/go.yaml'),
        },
        root_dir = function(fname)
          return lspconfig.util.root_pattern('go.mod', 'main.go')(fname)
        end,
        filetypes = { 'go', 'gomod' },
      }
    }
  end

  if not lspconfig.efm_general then
    configs.efm_general = {
      default_config = {
        cmd = {
          'efm-langserver',
          '-c',
          lspconfig.util.path.join(vim.loop.os_homedir(), '.config/efm-langserver/general.yaml'),
        },
        root_dir = lspconfig.util.path.dirname,
        filetypes = { 'sh', 'dockerfile' },
      }
    }
  end

  lspconfig.cssls.setup { on_attach = on_attach }
  lspconfig.html.setup { on_attach = on_attach }
  lspconfig.jsonls.setup { on_attach = on_attach }
  lspconfig.tsserver.setup {
    on_attach = function(client, bufnr)
      -- prettier is a better tool for formatting.
      -- So here we stop tsserver from formatting our code.
      client.resolved_capabilities.document_formatting = false
      on_attach(client, bufnr)
    end,
  }
  lspconfig.gopls.setup { on_attach = on_attach }
  lspconfig.efm_javascript.setup { on_attach = on_attach }
  lspconfig.efm_go.setup { on_attach = on_attach }
  lspconfig.efm_general.setup { on_attach = on_attach }
end
EOF

" Configure nvim-treesitter
lua <<EOF
local status, nvim_ts = pcall(require, 'nvim-treesitter.configs')
if (status) then
  nvim_ts.setup {
    ensure_installed = 'maintained',
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
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

" Configure nvim-colorizer
lua <<EOF
local status, colorizer = pcall(require, 'colorizer')
if (status) then
  colorizer.setup(nil, {
    css = true,
  })
end
EOF

augroup MyNeovimAutocommands
  autocmd!
  " https://neovim.io/news/2021/07
  autocmd TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}
augroup END
