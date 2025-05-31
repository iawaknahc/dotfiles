require("lz.n").load({
  "mini.clue",
  enabled = true,
  event = { "DeferredUIEnter" },
  after = function()
    local miniclue = require("mini.clue")
    miniclue.setup({
      window = {
        delay = 0,
        config = {
          width = "auto",
          anchor = "SE",
          row = "auto",
          col = "auto",
        },
      },
      triggers = {
        -- <Leader>
        { mode = "n", keys = "<Leader>" },
        { mode = "x", keys = "<Leader>" },
        -- g
        { mode = "n", keys = "g" },
        { mode = "x", keys = "g" },
        -- z
        { mode = "n", keys = "z" },
        { mode = "x", keys = "z" },
        -- ]
        { mode = "n", keys = "]" },
        { mode = "x", keys = "]" },
        -- [
        { mode = "n", keys = "[" },
        { mode = "x", keys = "[" },
        -- <Space>
        { mode = "n", keys = "<Space>" },

        -- Insert mode completion
        { mode = "i", keys = "<CTRL-X>" },

        -- Marks
        { mode = "n", keys = "'" },
        { mode = "n", keys = "`" },
        { mode = "x", keys = "'" },
        { mode = "x", keys = "`" },

        -- Registers
        { mode = "n", keys = '"' },
        { mode = "x", keys = '"' },
        { mode = "i", keys = "<CTRL-R>" },
        { mode = "c", keys = "<CTRL-R>" },

        -- Window commands
        { mode = "n", keys = "<CTRL-W>" },
      },
      clues = {
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.z(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),

        { mode = "n", keys = "<Leader>t", desc = "+Table mode" },

        { mode = "n", keys = "gr", desc = "+LSP" },

        { mode = "n", keys = "gs", desc = "+Surround" },
        { mode = "x", keys = "gs", desc = "+Surround" },
      },
    })

    miniclue.set_mapping_desc("n", "]d", "diagnostic")
    miniclue.set_mapping_desc("n", "]D", "Last diagnostic")
    miniclue.set_mapping_desc("n", "[d", "diagnostic")
    miniclue.set_mapping_desc("n", "[D", "First diagnostic")
  end,
})
