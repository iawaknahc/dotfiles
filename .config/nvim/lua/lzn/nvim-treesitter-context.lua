require("lz.n").load({
  "nvim-treesitter-context",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
})
