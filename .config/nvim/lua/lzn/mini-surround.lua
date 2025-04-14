require("lz.n").load({
  "mini.surround",
  event = { "DeferredUIEnter" },
  after = function()
    require("mini.surround").setup({
      -- Override :h s
      mappings = {
        add = "sa",
        delete = "sd",
        find = "",
        find_left = "",
        highlight = "",
        replace = "sr",
        update_n_lines = "",
        suffix_last = "",
        suffix_next = "",
      },
    })
  end,
})
