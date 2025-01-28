require("lz.n").load({
  "indent-blankline.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    require("ibl").setup({
      scope = {
        show_start = false,
        show_end = false,
      },
    })
  end,
})
