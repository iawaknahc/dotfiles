-- On 2025-06-24, I tried neovim 0.11 :h lsp-completion
-- The auto-complete without configuration depends on the language server's triggerCharacters.
-- It is very common that you hit backspace to delete some characters, and expect the completion to continues.
-- This is not possible out-of-the-box.
-- Thus an auto-completion plugin is still needed to fill this gap.
--
-- ---@type table<integer, string>
-- local kind_int_to_string = {}
-- for string_, int_ in pairs(vim.lsp.protocol.CompletionItemKind) do
--   kind_int_to_string[int_] = string_
-- end
--
-- vim.lsp.config("*", {
--   on_attach = function(client, bufnr)
--     if client:supports_method("textDocument/completion") then
--       vim.lsp.completion.enable(true, client.id, bufnr, {
--         autotrigger = true,
--
--         -- https://github.com/neovim/neovim/blob/v0.11.2/runtime/lua/vim/lsp/completion.lua#L328
--         ---@param item lsp.CompletionItem
--         ---@return table :h complete-items
--         convert = function(item)
--           return {
--             abbr = item.label:gsub("%b()", ""),
--             -- Use catppuccin's integration with blink.cmp to do highlight.
--             -- https://github.com/catppuccin/nvim/blob/v1.10.0/lua/catppuccin/groups/integrations/blink_cmp.lua
--             abbr_hlgroup = "BlinkCmpLabel",
--             kind_hlgroup = "BlinkCmpKind" .. (kind_int_to_string[item.kind] or "Unknown"),
--           }
--         end,
--       })
--     end
--   end,
-- })

local group = vim.api.nvim_create_augroup("MyLSP", { clear = true })

vim.lsp.enable("jsonls") -- JSON

-- vim.lsp.enable("marksman") -- Markdown
vim.lsp.enable("markdown_oxide") -- Markdown

vim.lsp.enable("yamlls") -- YAML
vim.lsp.enable("taplo") -- TOML
vim.lsp.enable("awk_ls") -- awk
vim.lsp.enable("bashls") -- Bash or sh

vim.lsp.enable("fish_lsp") -- fish
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.fish",
  callback = function(ev)
    local clients = vim.lsp.get_clients({ name = "fish_lsp", bufnr = ev.buf })
    if #clients == 1 then
      local stylua = clients[1]
      vim.lsp.buf.format({ bufnr = ev.buf, client = stylua.id, timeout_ms = 1000 })
    end
  end,
})

-- vim.lsp.enable("lua_ls") -- Lua
vim.lsp.enable("emmylua_ls") -- Lua

vim.lsp.enable("stylua") -- Lua formatter
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.lua",
  callback = function(ev)
    local clients = vim.lsp.get_clients({ name = "stylua", bufnr = ev.buf })
    if #clients == 1 then
      local stylua = clients[1]
      vim.lsp.buf.format({ bufnr = ev.buf, client = stylua.id, timeout_ms = 1000 })
    end
  end,
})

vim.lsp.enable("fennel_ls") -- Fennel
vim.lsp.enable("nil_ls") -- Nix
vim.lsp.enable("sqls") -- SQL
vim.lsp.enable("graphql") -- GraphQL
vim.lsp.enable("html") -- HTML
vim.lsp.enable("cssls") -- CSS
vim.lsp.enable("tailwindcss") -- Tailwindsss
vim.lsp.enable("pyright") -- Python

vim.lsp.enable("dartls") -- Dart
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.dart",
  callback = function(ev)
    local clients = vim.lsp.get_clients({ name = "dartls", bufnr = ev.buf })
    if #clients == 1 then
      local stylua = clients[1]
      vim.lsp.buf.format({ bufnr = ev.buf, client = stylua.id, timeout_ms = 1000 })
    end
  end,
})

vim.lsp.enable("eslint") -- ESLint
vim.lsp.enable("docker_compose_language_service") -- docker-compose.yaml
vim.lsp.enable("jdtls") -- Java

vim.lsp.enable("clojure_lsp") -- Clojure
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.clj",
  callback = function(ev)
    local clients = vim.lsp.get_clients({ name = "clojure_lsp", bufnr = ev.buf })
    if #clients == 1 then
      local stylua = clients[1]
      vim.lsp.buf.format({ bufnr = ev.buf, client = stylua.id, timeout_ms = 1000 })
    end
  end,
})

-- sourcekit is bundled with Xcode.
vim.lsp.enable("sourcekit") -- Swift, Objective-C, C, and C++

-- Grammar and spell checking
vim.lsp.config("harper_ls", {
  -- The default list from nvim-lspconfig is incomplete.
  -- This list is up-to-date as of 2026-04-17.
  -- https://writewithharper.com/docs/integrations/language-server#Supported-Languages
  filetypes = {
    "asciidoc",
    "c",
    "clojure",
    "cmake",
    "cpp",
    "cs",
    "dart",
    "gitcommit",
    "go",
    "groovy",
    "haskell",
    "html",
    "java",
    "javascript",
    "javascriptreact",
    "kotlin",
    "lua",
    "markdown",
    "nix",
    "php",
    "python",
    "ruby",
    "rust",
    "scala",
    "sh",
    "swift",
    "text",
    "toml",
    "typescript",
    "typescriptreact",
    "typst",
    "zig",
  },
})
vim.lsp.enable("harper_ls") -- https://writewithharper.com
vim.lsp.enable("typos_lsp") -- https://github.com/crate-ci/typos
vim.lsp.enable("codebook") -- https://github.com/blopker/codebook

vim.lsp.config("dockerls", {
  settings = {
    docker = {
      languageserver = {
        diagnostics = {
          deprecatedMaintainer = "error",
          directiveCasing = "error",
          emptyContinuationLine = "error",
          instructionCasing = "error",
          instructionCmdMultiple = "error",
          instructionEntrypointMultiple = "error",
          instructionHealthcheckMultiple = "error",
          instructionJSONInSingleQuotes = "error",
        },
      },
    },
  },
})
vim.lsp.enable("dockerls")

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      semanticTokens = true,
      -- No need to turn off @lsp.type.string and @lsp.type.number because we handled them in the LSP client side.
      -- semanticTokenTypes = {
      --   string = false,
      --   number = false,
      -- },
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
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.go,go.mod,go.sum,go.work,go.work.sum",
  callback = function(ev)
    local clients = vim.lsp.get_clients({ name = "gopls", bufnr = ev.buf })
    if #clients == 1 then
      local stylua = clients[1]
      vim.lsp.buf.format({ bufnr = ev.buf, client = stylua.id, timeout_ms = 1000 })
    end
  end,
})

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
-- vim.lsp.enable("ts_ls")
vim.lsp.config("vtsls", {
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = "all" },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
  },
})
vim.lsp.enable("vtsls")

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
      formatting = {
        command = { "nixfmt" },
      },
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
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.nix",
  callback = function(ev)
    local clients = vim.lsp.get_clients({ name = "nixd", bufnr = ev.buf })
    if #clients == 1 then
      local stylua = clients[1]
      vim.lsp.buf.format({ bufnr = ev.buf, client = stylua.id, timeout_ms = 1000 })
    end
  end,
})

vim.lsp.enable("zls")
