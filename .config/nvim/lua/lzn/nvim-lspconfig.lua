require("lz.n").load({
  "nvim-lspconfig",
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
    vim.lsp.enable("typos_lsp") -- Spell checking

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

    -- After trying inlay hint for some time,
    -- I found it quite annoying.
    -- So do not enable it initially.
    {
      "grh",
      function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
          bufnr = 0,
        }), {
          bufnr = 0,
        })
      end,
      desc = "Toggle inlay hints",
    },

    {
      "gx",
      function()
        local function gx()
          local word = vim.fn.expand("<cfile>")
          vim.ui.open(word)
        end

        --- @return vim.lsp.Client|nil
        local function get_gopls()
          local clients = vim.lsp.get_clients({
            name = "gopls",
            method = "textDocument/documentLink",
          })
          if #clients == 0 then
            return nil
          end
          return clients[1]
        end

        --- @param document_link lsp.DocumentLink
        --- @return boolean
        local function is_package_documentation_link(document_link)
          local target = document_link.target
          if target == nil then
            return false
          end
          if vim.startswith(target, "https://pkg.go.dev/") then
            return true
          end
          return false
        end

        ---@param pos lsp.Position
        ---@param range lsp.Range
        ---@return boolean
        local function is_in_range(pos, range)
          if pos.line > range.start.line and pos.line < range["end"].line then
            return true
          elseif pos.line == range.start.line and pos.line == range["end"].line then
            return pos.character >= range.start.character and pos.character <= range["end"].character
          elseif pos.line == range.start.line then
            return pos.character >= range.start.character
          elseif pos.line == range["end"].line then
            return pos.character <= range["end"].character
          else
            return false
          end
        end

        local gopls = get_gopls()
        if gopls == nil then
          gx()
          return
        end

        gopls:request(
          "textDocument/documentLink",
          vim.lsp.util.make_position_params(0, "utf-8"),
          function(err, result, context, _config)
            if err == nil then
              --- @type lsp.Position
              local cursor_position = context.params.position

              for _, item in ipairs(result) do
                --- @type lsp.DocumentLink
                local document_link = item
                local range = document_link.range
                if is_package_documentation_link(document_link) then
                  if is_in_range(cursor_position, range) then
                    vim.ui.open(document_link.target)
                    return
                  end
                end
              end
            end

            gx()
          end
        )
      end,
      desc = "Open textDocument/documentLink or fallback to gx",
    },
  },
})
