-- By default, :w will execute all queries in the buffer.
-- I think that is too dangerous.
vim.g.db_ui_execute_on_save = 0

-- Disable the default mappings in a SQL buffer.
vim.g.db_ui_disable_mappings_sql = 1

vim.g.db_ui_show_database_icon = 1
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_use_nvim_notify = 1

local my_dadbod_autocmd_group = vim.api.nvim_create_augroup("MyDadbod", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = my_dadbod_autocmd_group,
  pattern = "sql",
  callback = function(ev)
    -- The default keymap also works in normal mode, which execute all queries in the buffer.
    -- I think that is too dangerous.
    vim.keymap.set({ "x" }, "<Leader>S", "<Plug>(DBUI_ExecuteQuery)", {
      buf = ev.buf,
      desc = "DBUI: Execute selected query",
    })

    vim.keymap.set({ "n" }, "<Leader>W", "<Plug>(DBUI_SaveQuery)", {
      buf = ev.buf,
      desc = "DBUI: Save all queries to file",
    })
  end,
})

vim.cmd([[packadd vim-dadbod-ui]])
