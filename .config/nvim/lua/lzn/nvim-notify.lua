require("lz.n").load({
  "nvim-notify",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    vim.notify = require("notify")
  end,
})
