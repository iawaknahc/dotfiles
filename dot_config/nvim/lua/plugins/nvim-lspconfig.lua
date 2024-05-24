local simple = {
  -- Data
  "jsonls",
  "yamlls",
  "taplo",
  -- Scripting
  "awk_ls",
  "bashls",
  -- SQL
  "sqlls",
  -- GraphQL
  "graphql",
  -- Markup
  "html",
  "cssls",
  "tailwindcss",
  -- Programming
  "pyright",
  "dartls",
}

local function config()
  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  local lspconfig = require("lspconfig")

  for _, v in ipairs(simple) do
    lspconfig[v].setup {
      capabilities = capabilities,
    }
  end

  lspconfig["gopls"].setup {
    capabilities = capabilities,
    settings = {
      gopls = {
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  }

  lspconfig["tsserver"].setup {
    capabilities = capabilities,
    root_dir = lspconfig.util.root_pattern("package.json"),
    init_options = {
      -- https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
      preferences = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  }

  lspconfig["denols"].setup {
    capabilities = capabilities,
    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
  }

  lspconfig["lua_ls"].setup {
    capabilities = capabilities,
    -- Copied from https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
        return
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = {
          version = "LuaJIT",
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
      })
    end,
    settings = {
      Lua = {
        -- It is disabled by default.
        -- https://luals.github.io/wiki/settings/#hintenable
        hint = { enable = true },
      },
    },
  }

  local lspGroup = vim.api.nvim_create_augroup("MyLSPAutoCommands", { clear = true })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = lspGroup,
    callback = function(args)
      local bufnr = args.buf

      local map_opts = { noremap = true, buffer = bufnr }
      -- omnifunc and tagfunc are set by default.
      -- tagfunc is set, so CTRL-] works automatically.
      -- Since CTRL-] is vim.lsp.buf.definition, we need not map gd (Helix goto mode d)

      -- Inspired by gd
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)

      -- vim.lsp.buf.hover is mapped to K by default since neovim 0.10.0

      -- implementation is usually a list. It is handled by telescope.
      -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, map_opts)

      -- Inspired by Helix goto mode y
      vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, map_opts)
      -- Inspired by Helix space mode r
      vim.keymap.set("n", "<Leader>r", vim.lsp.buf.rename, map_opts)
      -- Inspired by Helix space mode a
      vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, map_opts)

      -- Toggle inlay hint
      vim.keymap.set("n", "<Leader>h", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, map_opts)
      vim.lsp.inlay_hint.enable()

      vim.bo[bufnr].fixendofline = true
    end,
  })
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = config,
  },
}
