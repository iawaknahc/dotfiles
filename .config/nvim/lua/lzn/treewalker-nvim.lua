require("lz.n").load({
  "treewalker.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    local treewalker = require("treewalker")
    treewalker.setup({
      highlight_duration = 250,
      highlight_group = "IncSearch",
    })
  end,
})
