-- Disable :h <Space>
vim.keymap.set("n", "<Space>", "<Nop>")

-- Disable :h s
vim.keymap.set({ "n", "x" }, "s", "<Nop>")

-- Disable :h S
vim.keymap.set({ "n", "x" }, "S", "<Nop>")

-- A better CTRL-L
vim.keymap.set("n", "<C-l>", "<Cmd>set hlsearch!<Bar>diffupdate<Bar>normal! <C-L><CR>", {
  desc = ":h CTRL-L-default with nohlsearch changed to hlsearch!",
})

-- Some quality of life insert mode keymaps.
vim.keymap.set({ "i", "c" }, [[<C-\><C-p>]], "<C-r>=getcwd()<CR>", {
  desc = "Insert getcwd()",
})
vim.keymap.set({ "i", "c" }, [[<C-\><C-a>]], [[<C-r>=expand("%:p")<CR>]], {
  desc = "Insert absolute path to current file",
})

-- Deterministic nN
vim.keymap.set({ "n", "x", "o" }, "n", "'Nn'[v:searchforward]", {
  desc = "Make n always search forward",
  expr = true,
})
vim.keymap.set({ "n", "x", "o" }, "N", "'nN'[v:searchforward]", {
  desc = "Make N always search backward",
  expr = true,
})
