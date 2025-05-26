require("lz.n").load({
  "gitsigns.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    require("gitsigns").setup({
      -- The default signs configuration is already single-column.
      -- So it is good enough.
    })
  end,
  keys = {
    {
      "]h",
      function()
        require("gitsigns").nav_hunk("next")
      end,
      desc = "Next hunk",
    },
    {
      "[h",
      function()
        require("gitsigns").nav_hunk("prev")
      end,
      desc = "Previous hunk",
    },
    {
      "]H",
      function()
        require("gitsigns").nav_hunk("last")
      end,
      desc = "Last hunk",
    },
    {
      "[H",
      function()
        require("gitsigns").nav_hunk("first")
      end,
      desc = "First hunk",
    },
    {
      "ih",
      function()
        require("gitsigns").select_hunk()
      end,
      mode = { "x", "o" },
      desc = "inner hunk",
    },
  },
})
