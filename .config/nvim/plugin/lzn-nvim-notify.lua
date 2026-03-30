require("lz.n").load({
  "nvim-notify",
  event = { "DeferredUIEnter" },
  after = function()
    vim.notify = require("notify")
  end,
})
