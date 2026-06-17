vim.keymap.set({ "n", "x", "o" }, "n", "'Nn'[v:searchforward]", {
  desc = "Make n always search forward",
  expr = true,
})
vim.keymap.set({ "n", "x", "o" }, "N", "'nN'[v:searchforward]", {
  desc = "Make N always search backward",
  expr = true,
})
