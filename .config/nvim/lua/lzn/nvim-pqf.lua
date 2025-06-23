require("lz.n").load({
  "nvim-pqf",
  enabled = vim.g.pager_enabled ~= 1,
  lazy = false,
  after = function()
    require("pqf").setup()
  end,
})
