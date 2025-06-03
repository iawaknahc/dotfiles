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
        -- IMPORTANT: <C-x> must be written as <C-x>, not <CTRL-x>
        -- Otherwise MiniClue is confused.

        -- IMPORTANT: You cannot create a trigger with @.
        -- See https://github.com/echasnovski/mini.nvim/issues/1603

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
        { mode = "i", keys = "<C-x>" },

        -- Marks
        { mode = "n", keys = "'" },
        { mode = "n", keys = "`" },
        { mode = "x", keys = "'" },
        { mode = "x", keys = "`" },

        -- Registers
        { mode = "n", keys = '"' },
        { mode = "x", keys = '"' },
        { mode = "i", keys = "<C-r>" },
        { mode = "c", keys = "<C-r>" },

        -- Window commands
        { mode = "n", keys = "<C-w>" },
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
