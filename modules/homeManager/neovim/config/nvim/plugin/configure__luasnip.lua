require("luasnip.loaders.from_lua").load({
  paths = {
    -- `./` means relative to `$MYVIMRC`, it DOES NOT mean relative to this file.
    -- See https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#loaders
    "./snippets",
  },
})

require("luasnip").setup({
  keep_roots = true,
  link_roots = true,
  link_children = true,
  exit_roots = false,
  update_events = { "InsertLeave", "TextChanged", "TextChangedI" },
  region_check_events = { "InsertEnter" },
})

-- Make CTRL-K works like CTRL-Y
vim.keymap.set({ "i", "s" }, "<C-K>", function()
  local ls = require("luasnip")
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  else
    require("blink.cmp").select_and_accept()
  end
end)

-- Since CTRL-K jumps forward, it follows naturally that CTRL-J jumps backward.
vim.keymap.set({ "i", "s" }, "<C-J>", function()
  local ls = require("luasnip")
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end)
