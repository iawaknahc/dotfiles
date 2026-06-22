-- When viewing a Fugitive object (a commit), view the commit with diffview.nvim
vim.api.nvim_create_user_command("DiffviewOpenFugitive", function()
  ---@type [string, string]
  local result = vim.fn.FugitiveParse()
  local commit_and_file = result[1]
  if commit_and_file ~= "" then
    local parts = vim.split(commit_and_file, ":")
    if #parts == 1 then
      vim.cmd(string.format("DiffviewOpen %s^!", commit_and_file))
    elseif #parts == 2 then
      local commit = parts[1]
      local path = parts[2]
      vim.cmd(string.format("DiffviewOpen %s^! -- %s", commit, path))
    end
  end
end, {
  desc = "DiffviewOpen commit^!",
})
