-- on_attach sets up things that are common to all LSP servers.
function on_attach(client, bufnr)
  local map_opts = { buffer = true }
  vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, map_opts)
  vim.keymap.set('n', '<C-]>', function() vim.lsp.buf.definition() end, map_opts)
  vim.keymap.set('n', 'g?', function() vim.diagnostic.open_float() end, map_opts)
  vim.keymap.set('n', 'ga', function() vim.lsp.buf.code_action() end, map_opts)
  vim.o.omnifunc = 'v:lua.vim.lsp.omnifunc'
  vim.o.fixendofline = true
  vim.o.completeopt = 'menu,menuone,noselect'
  local group = vim.api.nvim_create_augroup("LSPAutoCommands", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function() vim.lsp.buf.format() end,
    group = group,
  })
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    buffer = bufnr,
    callback = function() vim.diagnostic.setloclist({open = false}) end,
    group = group,
  })
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
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end
        on_attach(client, bufnr)
      end,
    }
  end

  -- Data
  setup("jsonls", {
    disable_formatting = true,
  })
  setup("yamlls", {
    disable_formatting = true,
  })
  setup("taplo", {
    disable_formatting = true,
  })

  -- Scripting
  setup("awk_ls", {
    disable_formatting = true,
  })
  setup("bashls", {
    disable_formatting = true,
  })

  -- SQL
  setup("sqls", {
    disable_formatting = true,
  })

  -- GraphQL
  setup("graphql", {
    disable_formatting = true,
  })

  -- Markup
  setup("html", {
    disable_formatting = true,
  })
  setup("cssls")
  setup("tailwindcss")

  -- Programming
  setup("gopls", {
    disable_formatting = true,
  })
  setup("tsserver", {
    disable_formatting = true,
  })
  setup("pyright")
  setup("denols", {
    disable_formatting = true,
  })
  setup("clojure_lsp")
  setup("rust_analyzer")
  setup("dartls")
  setup("ocamllsp")
  setup("sourcekit")
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

  local project_files = function()
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
  local registers = function()
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

  vim.keymap.set('n', '<Leader>f', project_files)
  vim.keymap.set('n', '<Leader>r', registers)
  vim.keymap.set('n', '<Leader>b', function() require('telescope.builtin').buffers() end)
  vim.keymap.set('n', '<Leader>g', function() require('telescope.builtin').live_grep() end)
end

local status, packer = pcall(require, 'packer')
if not status then return end

return packer.startup(function(use)
  -- This autocmd will cause errors if this file is saved a few times.
  -- vim.cmd [[autocmd BufWritePost plugins.lua source <afile> | PackerCompile]]

  use 'wbthomason/packer.nvim'
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
    'williamboman/mason.nvim',
    config = function()
      require("mason").setup()
    end,
  }
  use {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require("mason-lspconfig").setup({
        automatic_installation = true,
      })
    end,
    after = 'mason.nvim',
  }
  use {
    'neovim/nvim-lspconfig',
    after = 'mason-lspconfig.nvim',
    config = config_lspconfig,
  }
  use {
    'jose-elias-alvarez/null-ls.nvim',
    config = config_null_ls,
    requires = { 'nvim-lua/plenary.nvim' },
  }
  use {
    'jayp0521/mason-null-ls.nvim',
    after = {
      'null-ls.nvim',
      'mason.nvim',
    },
    config = function()
      require('mason-null-ls').setup({
        automatic_installation = true,
      })
    end,
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          "bash",
          "css",
          "dart",
          "dockerfile",
          "go",
          "gomod",
          "gowork",
          "graphql",
          -- "help",
          "html",
          "http",
          "java",
          "javascript",
          "json",
          "json5",
          "kotlin",
          "lua",
          "make",
          "ocaml",
          "ocaml_interface",
          "ocamllex",
          "python",
          "regex",
          "rust",
          "scss",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "yaml",
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      }
    end,
  }

  use {
    'nvim-telescope/telescope.nvim',
    config = config_telescope,
    requires = { 'nvim-lua/plenary.nvim' },
  }

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
