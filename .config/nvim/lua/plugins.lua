function config_lspconfig()
  local lspconfig = require('lspconfig')
  local configs = require('lspconfig/configs')

  local null_ls = require('null-ls')

  null_ls.config {
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

  -- on_attach sets up things that are common to all LSP servers.
  local on_attach = function(client, bufnr)
    local map_opts = { noremap = true }
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', map_opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-]>', '<Cmd>lua vim.lsp.buf.definition()<CR>', map_opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'g?', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', map_opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ga', '<Cmd>lua vim.lsp.buf.code_action()<CR>', map_opts)
    vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.o.completeopt = 'menu,menuone,noselect'
    vim.api.nvim_command[[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
    vim.api.nvim_command[[autocmd User LspDiagnosticsChanged lua vim.lsp.diagnostic.set_loclist({open_loclist = false})]]
  end

  -- Some language servers require snippet support to provide completion.
  -- We us nvim-cmp and luasnip together to provide snippet completion.
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown' }
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.preselectSupport = true
  capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
  capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
  capabilities.textDocument.completion.completionItem.deprecatedSupport = true
  capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
  capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      'documentation',
      'detail',
      'additionalTextEdits',
    }
  }

  lspconfig.cssls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
  }
  lspconfig.html.setup {
    capabilities = capabilities,
    on_attach = on_attach,
  }
  lspconfig.jsonls.setup {
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      on_attach(client, bufnr)
    end,
  }
  lspconfig.tsserver.setup {
    on_attach = function(client, bufnr)
      -- prettier is a better tool for formatting.
      -- So here we stop tsserver from formatting our code.
      client.resolved_capabilities.document_formatting = false
      on_attach(client, bufnr)
    end,
  }
  lspconfig.gopls.setup {
    on_attach = function(client, bufnr)
      -- gopls takes sometime to start up.
      -- It does not respond to format command during startup.
      client.resolved_capabilities.document_formatting = false
      on_attach(client, bufnr)
    end,
  }
  lspconfig.ocamllsp.setup { on_attach = on_attach }
  lspconfig.rls.setup { on_attach = on_attach }
  lspconfig.sqls.setup { on_attach = on_attach }
  lspconfig['null-ls'].setup { on_attach = on_attach }
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
  vim.cmd [[autocmd BufWritePost plugins.lua source <afile> | PackerCompile]]

  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'
  use { 'neovim/nvim-lspconfig' }
  use {
    'jose-elias-alvarez/null-ls.nvim',
    config = config_lspconfig,
    requires = {'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  }
  use {
    'nvim-treesitter/nvim-treesitter',
    branch = '0.5-compat',
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
  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end,
  }
  use {
    'hrsh7th/nvim-cmp',
    config = function()
      local cmp = require('cmp')
      cmp.setup {
        snippet = {
          expand = function(args)
            local luasnip = require('luasnip')
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          -- Ctrl-Space is my tmux prefix.
          -- nvim-cmp by default show completion menu when there is at least 1 character.
          -- To show the completion menu when there is no character, use omni completion.
          ['<C-e>'] = cmp.mapping.close(),
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
        },
        sources = {
          { name = 'nvim_lsp' },
          {
            name = 'buffer',
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()()
            end,
          },
          { name = 'path' },
        }
      }
    end,
  }
  use {
    'hrsh7th/cmp-nvim-lsp',
    config = function()
      require('cmp_nvim_lsp').setup()
    end,
  }
  use { 'hrsh7th/cmp-buffer' }
  use { 'hrsh7th/cmp-path' }
  -- luasnip is used to expand LSP snippet.
  -- We do not define any additional snippets.
  use {
    'L3MON4D3/LuaSnip',
    config = function()
      local luasnip = require('luasnip')

      function t(str)
        return vim.api.nvim_replace_termcodes(str, true, true, true)
      end

      _G.tab_complete = function()
        if vim.fn.pumvisible() == 1 then
          return t "<C-n>"
        elseif luasnip.expand_or_jumpable() then
          return t "<Plug>luasnip-expand-or-jump"
        else
          return t "<Tab>"
        end
      end

      _G.s_tab_complete = function()
        if vim.fn.pumvisible() == 1 then
          return t "<C-p>"
        elseif luasnip and luasnip.jumpable(-1) then
          return t "<Plug>luasnip-jump-prev"
        else
          return t "<S-Tab>"
        end
      end

      vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
      vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
      vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
      vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
    end,
  }
  -- indent-blankline does not work with listchars :(
  -- https://github.com/lukas-reineke/indent-blankline.nvim/issues/74
  -- use 'lukas-reineke/indent-blankline.nvim'
  use 'norcalli/nvim-colorizer.lua'
  use { 'dracula/vim', as = 'dracula' }
  use {
    'tpope/vim-sleuth',
    config = function()
      -- Prevent this plugin to turn on filetype indentation.
      -- https://github.com/tpope/vim-sleuth/blob/v1.2/plugin/sleuth.vim#L181
      vim.g.did_indent_on = true
    end,
  }
  use 'junegunn/vim-easy-align'
end)
