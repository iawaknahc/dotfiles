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

  lspconfig["ts_ls"].setup {
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
      vim.bo[bufnr].fixendofline = true
    end,
  })

  -- Disable inlay hint when entering insert mode.
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = lspGroup,
    callback = function(args)
      local bufnr = args.buf

      vim.b.inlay_hint_is_enabled = vim.lsp.inlay_hint.is_enabled({
        bufnr = bufnr,
      })

      vim.lsp.inlay_hint.enable(false, {
        bufnr = bufnr,
      })
    end,
  })

  -- Restore inlay hint when leaving insert mode.
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = lspGroup,
    callback = function(args)
      local bufnr = args.buf

      local is_enabled = vim.b.inlay_hint_is_enabled
      if is_enabled ~= nil then
        vim.lsp.inlay_hint.enable(is_enabled, {
          bufnr = bufnr,
        })
      end
    end,
  })
end

return {
  {
    "neovim/nvim-lspconfig",
    event = {
      -- According to :h lspconfig-setup, nvim-lspconfig starts
      -- LSP server in FileType event.
      "FileType",
    },
    keys = {
      -- omnifunc and tagfunc are set by default.
      -- tagfunc is set, so CTRL-] works automatically.
      -- Since CTRL-] is vim.lsp.buf.definition, we need not map gd (Helix goto mode d)

      -- Inspired by gd
      {
        "gD", vim.lsp.buf.declaration,
        desc = "Go to declaration",
      },

      -- Other LSP features are handled by telescope.

      -- Inspired by Helix goto mode y
      -- Technically speaking, this can be handled by telescope as well,
      -- as Telescope has builtin.lsp_type_definitions.
      {
        "gy", vim.lsp.buf.type_definition,
        desc = "Go to type definition",
      },

      -- Uncoming default mapping
      {
        "crn", vim.lsp.buf.rename,
        desc = "Rename",
      },

      -- After trying inlay hint for some time,
      -- I found it quite annoying.
      -- So do not enable it initially.
      {
        "<Leader>h", function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
            bufnr = 0,
          }), {
            bufnr = 0,
          })
        end,
        desc = "Toggle inlay hints",
      },
    },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = config,
  },
}
