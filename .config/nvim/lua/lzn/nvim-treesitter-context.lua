require("lz.n").load({
  "nvim-treesitter-context",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    vim.keymap.set("n", "<Leader>c", "<Cmd>TSContext toggle<CR>", {
      desc = "TSContext: toggle",
    })
  end,
})
