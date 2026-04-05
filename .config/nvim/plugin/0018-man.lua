local myman_autocmdgroup = vim.api.nvim_create_augroup("MyMan", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = myman_autocmdgroup,
  pattern = "man",
  desc = "Automatically execute gO and then close the loclist",
  callback = function()
    vim.cmd([[normal gO]])
    vim.cmd([[lclose]])
    -- So now the loclist is populated, and we can use fzf-lua to fuzzy search the entries.
  end,
})
