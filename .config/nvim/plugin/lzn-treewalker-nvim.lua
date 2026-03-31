local once = require("once")

local setup = once(function()
  local treewalker = require("treewalker")
  treewalker.setup({
    highlight_duration = 250,
    highlight_group = "IncSearch",
  })

  local fix_treesitter_function = require("fix_treesitter_function")
  local make_repeatable = require("dot-repeat").make_repeatable

  local actions = {
    swap_up = make_repeatable("treewalker_swap_up", fix_treesitter_function(treewalker.swap_up)),
    swap_right = make_repeatable("treewalker_swap_right", fix_treesitter_function(treewalker.swap_right)),
    swap_down = make_repeatable("treewalker_swap_down", fix_treesitter_function(treewalker.swap_down)),
    swap_left = make_repeatable("treewalker_swap_left", fix_treesitter_function(treewalker.swap_left)),
  }
  return actions
end)

vim.keymap.set("n", "<Leader>wk", function()
  return setup().swap_up()
end, { expr = true, desc = "Treewalker: Swap up" })
vim.keymap.set("n", "<Leader>wl", function()
  return setup().swap_right()
end, { expr = true, desc = "Treewalker: Swap right" })
vim.keymap.set("n", "<Leader>wj", function()
  return setup().swap_down()
end, { expr = true, desc = "Treewalker: Swap down" })
vim.keymap.set("n", "<Leader>wh", function()
  return setup().swap_left()
end, { expr = true, desc = "Treewalker: Swap left" })
