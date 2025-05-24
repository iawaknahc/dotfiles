require("lz.n").load({
  "gitsigns.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    require("gitsigns").setup({
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_", show_count = true },
        topdelete = { text = "‾", show_count = true },
        changedelete = { text = "~_" },
        untracked = { text = "┆" },
      },
      signs_staged = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_", show_count = true },
        topdelete = { text = "‾", show_count = true },
        changedelete = { text = "~_" },
      },
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
