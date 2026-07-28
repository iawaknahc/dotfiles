require("luasnip.loaders.from_lua").load({
  paths = {
    -- `./` means relative to `$MYVIMRC`, it DOES NOT mean relative to this file.
    -- See https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#loaders
    "./snippets",
  },
})

local types = require("luasnip.util.types")
require("luasnip").config.setup({
  keep_roots = true,
  link_roots = true,
  link_children = true,
  exit_roots = false,
  update_events = { "InsertLeave", "TextChanged", "TextChangedI" },
  region_check_events = { "InsertEnter" },
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { "Hit CTRL-L to choose", "Comment" } },
      },
    },
  },
})

vim.keymap.set({ "i", "s" }, "<C-K>", function()
  local ls = require("luasnip")
  if ls.expandable() then
    ls.expand()
  end
end)

vim.keymap.set({ "i", "s" }, "<Tab>", function()
  local ls = require("luasnip")
  if ls.jumpable(1) then
    ls.jump(1)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
  end
end)

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  local ls = require("luasnip")
  if ls.jumpable(-1) then
    ls.jump(-1)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
  end
end)

-- L is next to K and J.
vim.keymap.set({ "i", "s" }, "<C-L>", function()
  local ls = require("luasnip")
  if ls.choice_active() then
    require("luasnip.extras.select_choice")()
  end
end)
