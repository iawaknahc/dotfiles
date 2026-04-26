vim.g["conjure#mapping#def_word"] = false
vim.g["conjure#mapping#doc_word"] = false
vim.g["conjure#completion#omnifunc"] = false
vim.g["conjure#highlight#enabled"] = true
vim.g["conjure#filetypes"] = {
  "clojure",
  "fennel",
  "janet",
  "hy",
  "lua",
  "python",
  "ruby",
}

vim.cmd([[packadd conjure]])
