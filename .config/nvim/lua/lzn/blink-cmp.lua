require("lz.n").load({
  "blink.cmp",
  event = { "DeferredUIEnter" },
  after = function()
    -- TODO: The missing source is tmux.
    -- I have tried blink.compat with cmp-tmux
    -- The setup seems succeed (no error popping up), but see no completion items at all.

    -- Do not make buffer a fallback source
    -- I want to complete with buffer even LSP source has items.
    -- https://github.com/Saghen/blink.cmp/blob/v0.10.0/lua/blink/cmp/config/sources.lua
    local presets = require("blink.cmp.config.sources")
    local preset_default = presets.default
    preset_default.providers.lsp.fallbacks = nil
    preset_default.providers.path.fallbacks = nil

    require("blink.cmp").setup({
      appearance = {
        use_nvim_cmp_as_default = true,
      },
      sources = preset_default,
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
        -- In insert mode, Tab should insert a horizontal tab.
        -- Enter is more convenient than C-y.
        ["<CR>"] = { "accept", "fallback" },

        -- The default is C-space, which is my tmux prefix.
        ["<C-h>"] = { "show", "show_documentation", "hide_documentation" },
      },
      cmdline = {
        keymap = {
          -- The default is C-space, which is my tmux prefix.
          ["<C-h>"] = { "show", "fallback" },
        },
      },
    })
  end,
})
