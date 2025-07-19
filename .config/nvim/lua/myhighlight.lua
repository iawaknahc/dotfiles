local myhighlight_autocmdgroup = vim.api.nvim_create_augroup("MyHighlight", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = myhighlight_autocmdgroup,
  pattern = "*",
  callback = function()
    vim.hl.on_yank({
      timeout = 250,
    })
  end,
})
