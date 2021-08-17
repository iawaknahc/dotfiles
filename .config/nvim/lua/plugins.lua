function config_lspconfig()
  local lspconfig = require('lspconfig')
  local configs = require('lspconfig/configs')

  local null_ls = require("null-ls")
  null_ls.config {
    sources = {
      null_ls.builtins.formatting.gofmt,
    },
  }

  -- on_attach sets up things that are common to all LSP servers.
  local on_attach = function(client, bufnr)
    local map_opts = { noremap = true }
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', map_opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-]>', '<Cmd>lua vim.lsp.buf.definition()<CR>', map_opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'g?', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', map_opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ga', '<Cmd>lua vim.lsp.buf.code_action()<CR>', map_opts)
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
  lspconfig.efm_javascript.setup { on_attach = on_attach }
  lspconfig['null-ls'].setup { on_attach = on_attach }
  lspconfig.efm_general.setup { on_attach = on_attach }
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

  local map_opts = { noremap = true }
  vim.api.nvim_set_keymap('n', '<Leader>f', "<Cmd>lua require('telescope.builtin').git_files()<CR>", map_opts)
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
          ['<C-Space>'] = function(core, fallback)
            if vim.fn.pumvisible() == 1 then
              cmp.mapping.close()(core, fallback)
            else
              cmp.mapping.complete()(core)
            end
          end,
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
  use 'tversteeg/registers.nvim'
end)
