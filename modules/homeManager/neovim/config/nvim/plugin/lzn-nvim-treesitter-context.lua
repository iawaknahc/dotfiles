require("treesitter-context").setup({
  enable = true,
  max_lines = "10%", -- Limit the window showing the context to 10% of the height of the window showing the buffer.
  multiline_threshold = 1, -- Show only one line for each context.
})

vim.keymap.set("n", "<Leader>c", "<Cmd>TSContext toggle<CR>", {
  desc = "TSContext: toggle",
})
