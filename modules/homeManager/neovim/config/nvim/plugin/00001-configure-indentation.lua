-- The default is :filetype detection:ON plugin:ON indent:ON
-- We want to turn off ftplugin-based indentation.
vim.cmd([[filetype indent off]])

-- Show indentation for wrapped lines.
vim.o.breakindent = true

vim.api.nvim_create_user_command("Space", function(t)
  local n = tonumber(t.fargs[1])
  if n ~= nil then
    n = math.floor(n)
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
    n = math.floor(n)
    vim.bo.tabstop = n
    vim.bo.shiftwidth = n
    vim.bo.softtabstop = n
    vim.bo.expandtab = false
  end
end, {
  desc = "Use a tab of N width for indentation",
  nargs = 1,
})
