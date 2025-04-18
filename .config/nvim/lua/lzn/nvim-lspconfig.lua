require("lz.n").load({
  "nvim-lspconfig",
  after = function()
    -- TODO: Remove this when nvim >= 0.11
    -- See https://cmp.saghen.dev/installation.html
    require("lz.n").trigger_load("blink.cmp")
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    local lspconfig = require("lspconfig")

    local simple = {
      "jsonls", -- JSON
      "yamlls", -- YAML
      "taplo", -- TOML

      "awk_ls", -- awk
      "bashls", -- bash or sh
      "fish_lsp", -- fish

      "lua_ls", -- Lua

      "nil_ls", -- Nix

      "sqls", -- SQL
      "graphql", -- GraphQL

      "html", -- HTML
      "cssls", -- CSS
      "tailwindcss", -- Tailwindsss

      "pyright", -- Python
      "dartls", -- Dart

      "typos_lsp", -- Spell checking
    }
    for _, v in ipairs(simple) do
      lspconfig[v].setup({
        capabilities = capabilities,
      })
    end

    lspconfig["gopls"].setup({
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
    })

    lspconfig["ts_ls"].setup({
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
    })

    lspconfig["denols"].setup({
      capabilities = capabilities,
      root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
    })

    -- Known issue: inlay hint works only in `with pkgs; [ ... ]`
    -- See https://github.com/nix-community/nixd/issues/629#issuecomment-2558520043
    lspconfig["nixd"].setup({
      capabilities = capabilities,
      cmd = { "nixd", "--inlay-hints=true", "--semantic-tokens=true" },
      settings = {
        nixd = {
          nixpkgs = {
            expr = "import <nixpkgs> { }",
          },
          -- nixd requires us to provide an expression that will be evaluated the options set.
          -- To do this, we add for-nixd to NIX_PATH, and use a dummy machine nixd@nixd.
          options = {
            ["nix-darwin"] = {
              expr = "(builtins.getFlake (builtins.toString <for-nixd>)).darwinConfigurations.nixd.options",
            },
            ["home-manager"] = {
              expr = '(builtins.getFlake (builtins.toString <for-nixd>)).homeConfigurations."nixd@nixd".options',
            },
          },
        },
      },
    })

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
  end,
  event = { "FileType" },
  keys = {
    -- omnifunc and tagfunc are set by default.
    -- tagfunc is set, so CTRL-] works automatically.
    -- Since CTRL-] is vim.lsp.buf.definition, we need not map gd (Helix goto mode d)

    -- Inspired by gd
    {
      "gD",
      vim.lsp.buf.declaration,
      desc = "Go to declaration",
    },

    -- Other LSP features are handled by telescope.

    -- Inspired by Helix goto mode y
    -- Technically speaking, this can be handled by telescope as well,
    -- as Telescope has builtin.lsp_type_definitions.
    {
      "gy",
      vim.lsp.buf.type_definition,
      desc = "Go to type definition",
    },

    -- grn is vim.lsp.buf.rename()
    -- https://gpanders.com/blog/whats-new-in-neovim-0-11/#more-default-mappings

    -- grr is vim.lsp.buf.references()
    -- https://gpanders.com/blog/whats-new-in-neovim-0-11/#more-default-mappings
    -- But this opens the quickfix list, the UX is not as good as telescope.

    -- After trying inlay hint for some time,
    -- I found it quite annoying.
    -- So do not enable it initially.
    {
      "<Space>h",
      function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
          bufnr = 0,
        }), {
          bufnr = 0,
        })
      end,
      desc = "Toggle inlay hints",
    },
  },
})
