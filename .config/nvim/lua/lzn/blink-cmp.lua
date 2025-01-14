require("lz.n").load {
  "blink.cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  after = function()
    require("blink.cmp").setup({
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
        ["<CR>"] = { "accept", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
      },
    })
  end,
}
