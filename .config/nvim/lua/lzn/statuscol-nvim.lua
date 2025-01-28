require("lz.n").load({
  "statuscol.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    require("statuscol").setup()
  end,
})
