vim.keymap.set("n", "g8", function()
  require("g8").g8()
end, {
  desc = "Unicode: Print byte sequence in 'fileencoding'",
})
