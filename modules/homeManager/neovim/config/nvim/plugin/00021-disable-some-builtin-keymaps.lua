-- Disable :h <Space>
vim.keymap.set("n", "<Space>", "<Nop>")

-- Disable `:help s`
vim.keymap.set({ "n", "x" }, "s", "<Nop>")

-- Disable :h S
vim.keymap.set({ "n", "x" }, "S", "<Nop>")
