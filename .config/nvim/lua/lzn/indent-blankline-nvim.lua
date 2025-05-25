require("lz.n").load({
  "indent-blankline.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    require("ibl").setup({
      indent = {
        -- Make it look like :h 'foldcolumn'.
        char = "▏",
        highlight = "FoldColumn",
      },
      scope = {
        show_start = false,
        show_end = false,
      },
    })
  end,
})
