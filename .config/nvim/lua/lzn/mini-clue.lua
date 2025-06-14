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

        -- CTRL-X is a native submode of Insert mode.
        { mode = "i", keys = "<C-x>" },

        -- CTRL-\ is a native submode of citv
        { mode = "c", keys = [[<C-\>]] },
        { mode = "i", keys = [[<C-\>]] },
        { mode = "t", keys = [[<C-\>]] },
        { mode = "v", keys = [[<C-\>]] },

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

        -- CTRL-\
        { mode = "c", keys = [[<C-\><C-n>]], desc = "Back to normal mode" },
        { mode = "c", keys = [[<C-\><C-g>]], desc = "Back to normal mode" },
        { mode = "c", keys = [[<C-\>e]], desc = [[:h c_CTRL-\_e]] },
        { mode = "i", keys = [[<C-\><C-n>]], desc = "Back to normal mode" },
        { mode = "i", keys = [[<C-\><C-g>]], desc = "Back to normal mode" },
        { mode = "i", keys = [[<C-\><C-o>]], desc = "Like i_CTRL-O" },
        { mode = "t", keys = [[<C-\><C-n>]], desc = "Back to normal mode" },
        { mode = "t", keys = [[<C-\><C-o>]], desc = "Like i_CTRL-O" },
        { mode = "v", keys = [[<C-\><C-g>]], desc = "Back to normal mode" },

        { mode = "n", keys = "<Leader>t", desc = "+Table mode" },

        { mode = "n", keys = "gr", desc = "+LSP" },

        { mode = "n", keys = "<Leader>s", desc = "+Surround" },
        { mode = "x", keys = "<Leader>s", desc = "+Surround" },
      },
    })

    miniclue.set_mapping_desc("n", "]d", "diagnostic")
    miniclue.set_mapping_desc("n", "]D", "Last diagnostic")
    miniclue.set_mapping_desc("n", "[d", "diagnostic")
    miniclue.set_mapping_desc("n", "[D", "First diagnostic")
  end,
})
