local my_highlight_autocmd_group = vim.api.nvim_create_augroup("MyHighlight", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = my_highlight_autocmd_group,
  pattern = "*",
  callback = function()
    vim.hl.on_yank({
      timeout = 250,
    })
  end,
})
