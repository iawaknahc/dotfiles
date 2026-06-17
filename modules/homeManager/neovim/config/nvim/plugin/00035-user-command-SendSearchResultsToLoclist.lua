vim.api.nvim_create_user_command("SendSearchResultsToLoclist", function()
  vim.go.hlsearch = true
  vim.cmd([[lvimgrep //gj %]])
end, {
  desc = "Send search results to loclist",
})

vim.keymap.set("n", "<Space>/", "<CMD>SendSearchResultsToLoclist<CR>", {
  desc = "Send search results to loclist",
})
