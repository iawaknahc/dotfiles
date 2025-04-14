require("lz.n").load({
  "mini.surround",
  event = { "DeferredUIEnter" },
  after = function()
    require("mini.surround").setup({
      -- Override :h gs
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "",
        find_left = "",
        highlight = "",
        replace = "gsr",
        update_n_lines = "",
        suffix_last = "",
        suffix_next = "",
      },
    })
  end,
})
