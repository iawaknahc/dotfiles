vim.api.nvim_create_user_command("Space", function(t)
  local n = tonumber(t.fargs[1])
  if n ~= nil then
    vim.bo.tabstop = n
    vim.bo.shiftwidth = n
    vim.bo.softtabstop = n
    vim.bo.expandtab = true
  end
end, {
  desc = "Use N spaces for indentation",
  nargs = 1,
})

vim.api.nvim_create_user_command("Tab", function(t)
  local n = tonumber(t.fargs[1])
  if n ~= nil then
    vim.bo.tabstop = n
    vim.bo.shiftwidth = n
    vim.bo.softtabstop = n
    vim.bo.expandtab = false
  end
end, {
  desc = "Use a tab of N width for indentation",
  nargs = 1,
})

vim.api.nvim_create_user_command("Reverse", function(args)
  local line1 = args.line1
  local line2 = args.line2
  local command = string.format("%d,%dglobal/^/move %d", line1, line2, line1 - 1)
  vim.cmd(command)
  vim.notify(command)
end, {
  desc = "Reverse line order as in :help 12.4",
  range = "%",
})

-- :HighlightGroupAtCursor prints out the highlight groups at cursor.
-- Useful for debugging colorscheme.
-- The motivation was to debug why @diff.plus has a different green color from the colorscheme.
vim.api.nvim_create_user_command("HighlightGroupAtCursor", function()
  local win = 0
  local buf = vim.api.nvim_win_get_buf(win)
  local row1, col0 = unpack(vim.api.nvim_win_get_cursor(win))
  local captures = vim.treesitter.get_captures_at_pos(buf, row1 - 1, col0)
  print(vim.inspect(captures))
end, {
  nargs = 0,
})
