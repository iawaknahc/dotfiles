-- Inspired by gd
vim.keymap.set({ "n" }, "gD", function()
  vim.lsp.buf.declaration()
end, {
  desc = "Go to declaration",
})

-- I am aware that this keymap is builtin, but
-- we want to set anchor_bias to above because
-- it clashes with the dropdown of blink.cmp very often.
vim.keymap.set("i", "<C-s>", function()
  vim.lsp.buf.signature_help({
    focusable = false,
    anchor_bias = "above",
    max_height = 30,
    max_width = 80,
  })
end, {
  desc = "vim.lsp.buf.signature_help()",
})
