vim.api.nvim_create_user_command("Reverse", function(args)
  local line1 = args.line1
  local line2 = args.line2
  local command = string.format("%d,%d" .. "global/^/move %d", line1, line2, line1 - 1)
  vim.cmd(command)
  vim.notify(command)
end, {
  desc = "Reverse line order as in :help 12.4",
  range = "%",
})
