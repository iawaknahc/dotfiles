require("lz.n").load({
  "conjure",
  event = { "DeferredUIEnter" },
  before = function()
    vim.g["conjure#mapping#def_word"] = false
    vim.g["conjure#mapping#doc_word"] = false

    vim.g["conjure#completion#omnifunc"] = false

    vim.g["conjure#highlight#enabled"] = true
  end,
})
