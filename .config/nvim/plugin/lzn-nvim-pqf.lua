require("lz.n").load({
  "nvim-pqf",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    require("pqf").setup()
  end,
})
