require("lz.n").load({
  "vim-table-mode",
  event = { "DeferredUIEnter" },
  before = function()
    vim.g.table_mode_motion_right_map = "<Tab>"
    vim.g.table_mode_motion_left_map = "<S-Tab>"
  end,
})
