require("lz.n").load({
  "blink.cmp",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    require("blink.cmp").setup({
      sources = {
        default = { "lsp", "snippets", "path", "buffer" },
        per_filetype = {},
        transform_items = function(_, items)
          return items
        end,
        min_keyword_length = 0,
        providers = {
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
          },
          path = {
            name = "Path",
            module = "blink.cmp.sources.path",
            opts = {
              get_cwd = function(_)
                return vim.fn.getcwd()
              end,
            },
          },
          snippets = {
            name = "Snippets",
            module = "blink.cmp.sources.snippets",
            override = {
              -- As of 2025-07-01, blink.cmp has an issue of not triggering when
              -- the snippet prefix is a non-alphabetical character.
              -- https://github.com/Saghen/blink.cmp/issues/1688
              --
              -- We work around this by completely override get_trigger_characters().
              -- The trigger_characters is just all ASCII characters that are printable.
              get_trigger_characters = function()
                local trigger_characters = {}
                for i = 32, 126, 1 do
                  table.insert(trigger_characters, vim.fn.nr2char(i))
                end
                return trigger_characters
              end,
            },
          },
          buffer = {
            name = "Buffer",
            module = "blink.cmp.sources.buffer",
          },
        },
      },
      completion = {
        list = {
          selection = {
            -- preselect has to be false, otherwise typing in Ex command
            -- pre-selects the first item, hitting enter will not run what I just typed.
            preselect = false,
            auto_insert = true,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 50,
        },
        menu = {
          draw = {
            columns = {
              { "label", "label_description", "kind", "source_name", gap = 1 },
            },
          },
        },
      },
      keymap = {
        preset = "none",
        -- There is no i_CTRL-Z.
        -- :h c_CTRL-Z is used to trigger :h 'wildmode'
        -- So we borrow that concept to Insert mode.
        ["<C-z>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-y>"] = { "select_and_accept", "fallback" },
        -- :h i_CTRL-P triggers the builtin completion.
        ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
        -- :h i_CTRL-N triggers the builtin completion.
        ["<C-n>"] = { "select_next", "fallback_to_mappings" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      cmdline = {
        -- Actually :h cmdline-completion is better than blink.cmp.
        enabled = false,
      },
    })
  end,
})
