require("lz.n").load({
  "mini.surround",
  event = { "DeferredUIEnter" },
  after = function()
    require("mini.surround").setup({
      mappings = {
        add = "<Leader>sa",
        delete = "<Leader>sd",
        find = "",
        find_left = "",
        highlight = "",
        replace = "<Leader>sr",
        update_n_lines = "",
        suffix_last = "",
        suffix_next = "",
      },
    })
  end,
})
