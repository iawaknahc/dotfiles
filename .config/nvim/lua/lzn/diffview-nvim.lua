require("lz.n").load({
  "diffview.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  -- Eagerly load it so that `nvim +DiffviewFileHistory` works as expected.
  lazy = false,
  after = function()
    require("diffview").setup({})
  end,
})
