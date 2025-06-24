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
        preset = "default",

        -- The default is C-space, which is my tmux prefix.
        ["<C-space>"] = {},

        -- There is no i_CTRL-Z.
        -- :h c_CTRL-Z is used to trigger :h 'wildmode'
        -- So we borrow that concept to Insert mode.
        ["<C-z>"] = { "show", "show_documentation", "hide_documentation" },

        -- :h complete_CTRL-Y is used to accept the selected entry.
        -- So we just follow it.
      },
      cmdline = {
        -- Actually :h cmdline-completion is better than blink.cmp.
        enabled = false,
      },
    })
  end,
})
