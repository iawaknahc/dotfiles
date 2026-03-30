require("lz.n").load({
  "nvim-treesitter-context",
  event = { "DeferredUIEnter" },
  after = function()
    vim.keymap.set("n", "<Leader>c", "<Cmd>TSContext toggle<CR>", {
      desc = "TSContext: toggle",
    })
  end,
})
