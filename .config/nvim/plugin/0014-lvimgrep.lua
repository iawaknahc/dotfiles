vim.keymap.set("n", "<M-/>", ":Lvimgrep<Space>", {
  desc = "/ to loclist",
})

vim.api.nvim_create_user_command("Lvimgrep", function(args)
  local pattern = args.args

  -- https://github.com/neovim/neovim/pull/34215
  ---@diagnostic disable-next-line: redundant-parameter
  local original_pattern = vim.fn.getreg("/", 1, false)
  local win = vim.fn.winnr()

  if pattern ~= "" then
    vim.fn.setreg("/", pattern)
  elseif original_pattern == "" then
    vim.notify("No last pattern", vim.log.levels.WARN)
    return
  end

  vim.o.hlsearch = true
  local ok = pcall(function()
    vim.cmd([[lvimgrep //gj %]])
  end)
  if not ok then
    vim.notify("No matches", vim.log.levels.WARN)
  else
    -- TODO: select the selected entry to the closest cursor position.
    vim.schedule(function()
      vim.cmd(win .. [[wincmd w]])
    end)
  end
end, {
  desc = "/ to loclist",
  nargs = "*",
})
