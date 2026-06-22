-- :help CTRL-W_c closes the window.
-- So CTRL-W_C closes the tab page.
vim.keymap.set({ "n" }, "<C-W>C", "<Cmd>tabclose<CR>", { desc = ":tabclose" })
