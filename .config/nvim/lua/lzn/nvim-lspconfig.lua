require("lz.n").load({
  "nvim-lspconfig",
  lazy = false,
  after = function()
    vim.lsp.enable("jsonls") -- JSON
    vim.lsp.enable("marksman") -- Markdown
    vim.lsp.enable("yamlls") -- YAML
    vim.lsp.enable("taplo") -- TOML
    vim.lsp.enable("awk_ls") -- awk
    vim.lsp.enable("bashls") -- Bash or sh
    vim.lsp.enable("fish_lsp") -- fish
    vim.lsp.enable("lua_ls") -- Lua
    vim.lsp.enable("nil_ls") -- Nix
    vim.lsp.enable("sqls") -- SQL
    vim.lsp.enable("graphql") -- GraphQL
    vim.lsp.enable("html") -- HTML
    vim.lsp.enable("cssls") -- CSS
    vim.lsp.enable("tailwindcss") -- Tailwindsss
    vim.lsp.enable("pyright") -- Python
    vim.lsp.enable("dartls") -- Dart
    vim.lsp.enable("eslint") -- ESLint

    -- Grammar and spell checking
    vim.lsp.enable("harper_ls") -- https://writewithharper.com
    vim.lsp.enable("typos_lsp") -- https://github.com/crate-ci/typos

    vim.lsp.config("gopls", {
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
    vim.lsp.enable("gopls")

    vim.lsp.config("ts_ls", {
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
    vim.lsp.enable("ts_ls")

    vim.lsp.config("denols", {
      root_markers = { "deno.json", "deno.jsonc" },
    })
    vim.lsp.enable("denols")

    -- Known issue: inlay hint works only in `with pkgs; [ ... ]`
    -- See https://github.com/nix-community/nixd/issues/629#issuecomment-2558520043
    vim.lsp.config("nixd", {
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
    vim.lsp.enable("nixd")
  end,
})
