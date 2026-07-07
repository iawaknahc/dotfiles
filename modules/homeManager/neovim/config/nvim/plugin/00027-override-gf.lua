-- I found that both vim and neovim does not handle the case that
-- the file under cursor does not exist yet.
--
-- In :help gf, it is suggested that you can
-- :map gf :edit <cfile><CR>
-- But that does not seem to handle path like ../.foo/bar
vim.keymap.set("n", "gf", function()
  local cfile = vim.fn.expand("<cfile>") --[[@as string]]
  -- Absolute path or relative path to HOME
  if vim.startswith(cfile, "/") or vim.startswith(cfile, "~/") then
    vim.cmd([[edit ]] .. vim.fn.fnameescape(cfile))
    return
  end

  -- Otherwise, we construct a path relative to the current file.
  local dirname = vim.fn.expand("%:h") --[[@as string]]
  vim.cmd([[edit ]] .. vim.fn.fnameescape(vim.fs.normalize(vim.fs.joinpath(dirname, cfile))))
end, {
  desc = "Edit file under cursor",
})
