vim.keymap.set("n", "gf", function()
  -- I found that both vim and neovim does not handle the case that
  -- the file under cursor does not exist yet.
  --
  -- In :help gf, it is suggested that you can
  -- :map gf :edit <cfile><CR>
  -- But that does not seem to handle path like ../.foo/bar

  local file_under_cursor = vim.fn.expand("<cfile>")

  -- Absolute path
  if vim.startswith(file_under_cursor, "/") then
    -- Fallback to original gf.
    vim.cmd([[normal! gf]])
    return
  end

  -- Otherwise we construct a path relative to the current file.
  local parent_directory = vim.fn.expand("%:h")
  local path = vim.fs.joinpath(parent_directory, file_under_cursor)
  local normalized = vim.fs.normalize(path)
  local fname = vim.fn.fnameescape(normalized)
  vim.cmd([[edit ]] .. fname)
end, {
  desc = "Edit file under cursor",
})

vim.keymap.set("n", "g8", function()
  require("g8").g8()
end, {
  desc = "Unicode: Print byte sequence in 'fileencoding'",
})
