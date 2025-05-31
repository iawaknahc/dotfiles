require("lz.n").load({
  "diffview.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    require("diffview").setup({})
  end,
})
