-- Navigate hunks.
vim.keymap.set({ "n", "x", "o" }, "]h", function()
  require("gitsigns").nav_hunk("next")
end, { desc = "Gitsigns: next hunk" })
vim.keymap.set({ "n", "x", "o" }, "[h", function()
  require("gitsigns").nav_hunk("prev")
end, { desc = "Gitsigns: prev hunk" })
vim.keymap.set({ "n", "x", "o" }, "]H", function()
  require("gitsigns").nav_hunk("last")
end, { desc = "Gitsigns: last hunk" })
vim.keymap.set({ "n", "x", "o" }, "[H", function()
  require("gitsigns").nav_hunk("first")
end, { desc = "Gitsigns: first hunk" })

-- Stage hunks and discard hunks.
vim.keymap.set({ "n" }, "<leader>hs", function()
  require("gitsigns").stage_hunk()
end, { desc = "Gitsigns: stage hunk" })
vim.keymap.set({ "v" }, "<leader>hs", function()
  require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Gitsigns: stage selection" })
vim.keymap.set({ "n" }, "<leader>hd", function()
  require("gitsigns").reset_buffer()
end, { desc = "Gitsigns: discard hunk" })
vim.keymap.set({ "v" }, "<leader>hd", function()
  require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Gitsigns: discard selection" })

vim.keymap.set({ "x", "o" }, "ih", function()
  require("gitsigns").select_hunk()
end, { desc = "inner hunk" })

vim.keymap.set("n", "<Space>h", function()
  local buf = 0
  require("gitsigns").setqflist(buf, {
    use_location_list = true,
    open = true,
  })
end, { desc = "Gitsigns: unstaged hunks to loclist" })

vim.keymap.set("n", "<Space>H", function()
  require("gitsigns").setqflist("all", {
    use_location_list = false,
    open = true,
  })
end, { desc = "Gitsigns: unstaged hunks to qflist" })

require("gitsigns").setup({
  current_line_blame_opts = {
    delay = 100,
  },
})
