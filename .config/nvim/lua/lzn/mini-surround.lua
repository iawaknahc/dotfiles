require("lz.n").load({
  "mini.surround",
  enabled = vim.g.pager_enabled ~= 1,
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
