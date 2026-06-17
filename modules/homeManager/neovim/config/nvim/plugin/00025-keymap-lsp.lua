-- Inspired by gd
vim.keymap.set({ "n" }, "gD", function()
  vim.lsp.buf.declaration()
end, {
  desc = "Go to declaration",
})
