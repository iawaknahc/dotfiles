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
      "<Leader>ghs",
      ":Gitsigns stage_hunk<CR>",
      mode = { "n", "v" },
      desc = "Stage/unstage hunk",
    },
    {
      "<Leader>ghd",
      ":Gitsigns reset_hunk<CR>",
      mode = { "n", "v" },
      desc = "Discard unstaged hunk",
    },
    {
      "<Leader>ghb",
      function()
        require("gitsigns").stage_buffer()
      end,
      desc = "Stage buffer",
    },
    {
      "<Leader>ghB",
      function()
        require("gitsigns").reset_buffer_index()
      end,
      desc = "Unstage buffer",
    },
    {
      "<Leader>ghu",
      function()
        require("gitsigns").undo_stage_hunk()
      end,
      desc = "Undo last staged hunk",
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
