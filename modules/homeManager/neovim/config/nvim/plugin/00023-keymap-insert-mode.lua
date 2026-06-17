vim.keymap.set({ "i", "c" }, [[<C-\><C-p>]], "<C-r>=getcwd()<CR>", {
  desc = "Insert getcwd()",
})
vim.keymap.set({ "i", "c" }, [[<C-\><C-a>]], [[<C-r>=expand("%:p")<CR>]], {
  desc = "Insert absolute path to current file",
})
