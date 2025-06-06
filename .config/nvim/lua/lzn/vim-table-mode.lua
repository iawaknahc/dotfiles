require("lz.n").load({
  "vim-table-mode",
  enabled = vim.g.pager_enabled ~= 1,
  -- If this plugin is loaded too late, its filetype plugin is not run.
  -- One observable consequence is that b:table_mode_corner is not set for markdown.
  lazy = false,
  before = function()
    vim.g.table_mode_motion_right_map = "<Tab>"
    vim.g.table_mode_motion_left_map = "<S-Tab>"
  end,
})
