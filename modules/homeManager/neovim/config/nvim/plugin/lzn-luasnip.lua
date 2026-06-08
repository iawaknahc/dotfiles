require("luasnip.loaders.from_vscode").load({
  paths = {
    -- `./` means relative to `$MYVIMRC`, it DOES NOT mean relative to this file.
    -- See https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#loaders
    "./snippets",
  },
})
