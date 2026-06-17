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
