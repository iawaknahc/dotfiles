-- Disable the default mappings.
vim.g.Unicode_no_default_mappings = true
-- Use the UnicodeData.txt installed by unicode-character-database
vim.g.Unicode_data_directory = vim.fn.expand("~/.nix-profile/share/unicode")

vim.cmd([[packadd unicode.vim]])

vim.keymap.set("n", "ga", "<Plug>(UnicodeGA)", {
  desc = "Unicode: enhanced ga",
})
