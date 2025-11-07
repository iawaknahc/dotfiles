vim.api.nvim_create_user_command("Lcd", function(opts)
  -- :Lcd! to change current-directory to the global working-directory.
  if opts.bang then
    -- :help getcwd() says -1, -1 means the global working-directory.
    local target_dir = vim.fn.getcwd(-1, -1)
    vim.cmd.lcd(target_dir)
    vim.cmd([[verbose pwd]])
    return
  end

  -- This could be a URI, for example, "oil:///a/b"
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    vim.notify("This buffer is not associated with a file.", vim.log.levels.WARN)
    return
  end

  local bufpath = ""
  local split_result = require("python_urllib_parse").urlsplit(bufname)
  if split_result.netloc ~= "" and split_result.path == "" then
    bufpath = split_result.netloc
  elseif split_result.path ~= "" then
    bufpath = split_result.path
  end
  if bufpath == "" then
    vim.notify("No idea what this is: " .. bufname, vim.log.levels.WARN)
    return
  end

  local stat = vim.uv.fs_stat(bufpath)

  local target_dir
  if stat and stat.type == "directory" then
    target_dir = bufpath
  else
    target_dir = vim.fn.fnamemodify(bufpath, ":h")
  end

  vim.cmd.lcd(target_dir)
  vim.cmd([[verbose pwd]])
end, {
  bang = true,
  desc = "current-directory to current buffer",
})
