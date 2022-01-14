-- on_attach sets up things that are common to all LSP servers.
function on_attach(client, bufnr)
  local map_opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-]>', '<Cmd>lua vim.lsp.buf.definition()<CR>', map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'g?', '<Cmd>lua vim.diagnostic.open_float()<CR>', map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ga', '<Cmd>lua vim.lsp.buf.code_action()<CR>', map_opts)
  vim.o.omnifunc = 'v:lua.vim.lsp.omnifunc'
  vim.o.fixendofline = true
  vim.o.completeopt = 'menu,menuone,noselect'
  vim.cmd [[
    augroup MyLSPAutoCommands
      autocmd! * <buffer>
      autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
      autocmd DiagnosticChanged <buffer> lua vim.diagnostic.setloclist({open = false})
    augroup END
  ]]
end

function config_null_ls()
  local null_ls = require('null-ls')

  null_ls.setup {
    on_attach = on_attach,
    sources = {
      null_ls.builtins.diagnostics.shellcheck,
      null_ls.builtins.diagnostics.hadolint,
      null_ls.builtins.formatting.gofmt,
      null_ls.builtins.diagnostics.eslint_d,
      null_ls.builtins.formatting.prettierd.with {
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          -- "css",
          -- "scss",
          -- "html",
        }
      },
    },
  }
end

function config_lspconfig()
  local lspconfig = require('lspconfig')
  local configs = require('lspconfig/configs')

  local setup = function(server_name, opts)
    local opts = opts or {}
    local disable_formatting = opts.disable_formatting or false
    lspconfig[server_name].setup {
      on_attach = function(client, bufnr)
        if disable_formatting then
          client.resolved_capabilities.document_formatting = false
          client.resolved_capabilities.document_range_formatting = false
        end
        on_attach(client, bufnr)
      end,
    }
  end

  setup("cssls")
  setup("html")
  setup("jsonls", {
    disable_formatting = true,
  })
  setup("tsserver", {
    disable_formatting = true,
  })
  setup("gopls", {
    disable_formatting = true,
  })
  setup("rls")
  setup("sqls")
  setup("pyright")
end

function config_telescope()
  local actions = require('telescope.actions')
  require('telescope').setup {
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

  _G.project_files = function()
    local git_files = require("telescope.builtin").git_files
    local find_files = require("telescope.builtin").find_files
    local ok = pcall(git_files, {
      use_git_root = false,
    })
    if not ok then
      find_files({
        find_command = {
          "find",
          ".",
          "-type",
          "f",
          "-maxdepth",
          "2",
        },
      })
    end
  end

  -- registers() is require("telescope.builtin").registers()
  -- except that only nonempty registers are shown.
  _G.registers = function()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local make_entry = require("telescope.make_entry")
    local sorters = require("telescope.sorters")
    local actions = require("telescope.actions")
    local opts = {}

    local all_registers = { '"', "_", "#", "=", "_", "/", "*", "+", ":", ".", "%" }
    for i = 0, 9 do
      table.insert(all_registers, tostring(i))
    end
    for i = 65, 90 do
      table.insert(all_registers, string.char(i))
    end

    local nonempty_registers = {}
    for i, v in ipairs(all_registers) do
      if vim.trim(vim.fn.getreg(v)) ~= "" then
        table.insert(nonempty_registers, v)
      end
    end

    pickers.new(opts, {
      prompt_title = "Registers",
      finder = finders.new_table {
        results = nonempty_registers,
        entry_maker = make_entry.gen_from_registers(opts),
      },
      sorter = sorters.get_levenshtein_sorter(),
      attach_mappings = function(_, map)
        actions.select_default:replace(actions.paste_register)
        map("i", "<C-e>", actions.edit_register)
        return true
      end,
    }):find()
  end

  local map_opts = { noremap = true }
  vim.api.nvim_set_keymap('n', '<Leader>f', "<Cmd>lua _G.project_files()<CR>", map_opts)
  vim.api.nvim_set_keymap('n', '<Leader>r', "<Cmd>lua _G.registers()<CR>", map_opts)
  vim.api.nvim_set_keymap('n', '<Leader>b', "<Cmd>lua require('telescope.builtin').buffers()<CR>", map_opts)
  vim.api.nvim_set_keymap('n', '<Leader>g', "<Cmd>lua require('telescope.builtin').live_grep()<CR>", map_opts)
end

local status, packer = pcall(require, 'packer')
if not status then return end

return packer.startup(function(use)
  -- This autocmd will cause errors if this file is saved a few times.
  -- vim.cmd [[autocmd BufWritePost plugins.lua source <afile> | PackerCompile]]

  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'norcalli/nvim-colorizer.lua'
  use { 'dracula/vim', as = 'dracula' }
  use 'junegunn/vim-easy-align'
  -- indent-blankline does not work with listchars :(
  -- https://github.com/lukas-reineke/indent-blankline.nvim/issues/74
  -- use 'lukas-reineke/indent-blankline.nvim'

  use {
    'tpope/vim-sleuth',
    config = function()
      -- Prevent this plugin to turn on filetype indentation.
      -- https://github.com/tpope/vim-sleuth/blob/v1.2/plugin/sleuth.vim#L181
      vim.g.did_indent_on = true
    end,
  }

  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end,
  }

  use {
    'neovim/nvim-lspconfig',
    config = config_lspconfig,
  }
  use {
    'jose-elias-alvarez/null-ls.nvim',
    config = config_null_ls,
    requires = { 'nvim-lua/plenary.nvim' },
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = 'maintained',
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      }
    end,
  }

  use 'nvim-lua/popup.nvim'
  use { 'nvim-telescope/telescope.nvim', config = config_telescope }

  -- Use C-h to jump to the next snippet mark.
  use {
    'ms-jpq/coq_nvim',
    branch = 'coq',
    config = function()
      local coq_settings = {}
      coq_settings["auto_start"] = "shut-up"
      coq_settings["display.icons.mode"] = "none"
      vim.g.coq_settings = coq_settings
    end,
  }
end)