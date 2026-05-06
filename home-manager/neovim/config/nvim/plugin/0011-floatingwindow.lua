vim.api.nvim_create_user_command("CloseFloatingWindows", function()
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then -- is floating window
      local force = false
      vim.api.nvim_win_close(win, force)
    end
  end
end, {
  nargs = 0,
})

-- Override :h i_CTRL-Q
vim.keymap.set("i", "<C-q>", "<Cmd>CloseFloatingWindows<CR>", {
  desc = ":CloseFloatingWindows",
})
