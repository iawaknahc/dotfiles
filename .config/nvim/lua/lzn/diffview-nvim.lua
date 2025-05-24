require("lz.n").load({
  "diffview.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    require("diffview").setup({})
  end,
})
