vim.api.nvim_create_user_command("Lcd", function(opts)
  -- :Lcd! to change current-directory to the global working-directory.
  if opts.bang then
    -- :help getcwd() says -1, -1 means the global working-directory.
    local target_dir = vim.fn.getcwd(-1, -1)
    vim.cmd.lcd(target_dir)
    vim.cmd([[verbose pwd]])
    return
  end

  local target_dir = require("get_buffer_directory")(0)
  if target_dir == nil then
    return
  end

  vim.cmd.lcd(target_dir)
  vim.cmd([[verbose pwd]])
end, {
  bang = true,
  desc = "current-directory to current buffer",
})
