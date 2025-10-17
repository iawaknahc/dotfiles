require("lz.n").load({
  "conjure",
  enabled = vim.g.pager_enabled ~= 1,
  lazy = false,
  before = function()
    vim.g["conjure#mapping#def_word"] = false
    vim.g["conjure#mapping#doc_word"] = false

    vim.g["conjure#completion#omnifunc"] = false

    vim.g["conjure#highlight#enabled"] = true
  end,
})
