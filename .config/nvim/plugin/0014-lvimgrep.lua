vim.keymap.set("n", "<Space>/", function()
  vim.go.hlsearch = true
  vim.cmd([[lvimgrep //gj %]])
end, {
  desc = "Send search results to loclist",
})
