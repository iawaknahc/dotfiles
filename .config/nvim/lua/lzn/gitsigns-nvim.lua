require("lz.n").load({
  "gitsigns.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    require("gitsigns").setup({
      -- The default signs configuration is already single-column.
      -- So it is good enough.

      -- I wanted to set numhl = true,
      -- But it does not work with cursorlineopt=number.
      -- See https://www.reddit.com/r/neovim/comments/1dto43b/use_cursorlinenr_highlight_instead_of_gitsigns/

      vim.keymap.set({ "n", "x", "o" }, "]h", function()
        require("gitsigns").nav_hunk("next")
      end, { desc = "Next hunk" }),
      vim.keymap.set({ "n", "x", "o" }, "[h", function()
        require("gitsigns").nav_hunk("prev")
      end, { desc = "Previous hunk" }),
      vim.keymap.set({ "n", "x", "o" }, "]H", function()
        require("gitsigns").nav_hunk("last")
      end, { desc = "Last hunk" }),
      vim.keymap.set({ "n", "x", "o" }, "[H", function()
        require("gitsigns").nav_hunk("first")
      end, { desc = "First hunk" }),

      vim.keymap.set({ "x", "o" }, "ih", function()
        require("gitsigns").select_hunk()
      end, { desc = "inner hunk" }),
    })
  end,
})
