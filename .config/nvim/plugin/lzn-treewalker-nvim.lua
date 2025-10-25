require("lz.n").load({
  "treewalker.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    local treewalker = require("treewalker")
    local fix_treesitter_function = require("fix_treesitter_function")

    treewalker.setup({
      highlight_duration = 250,
      highlight_group = "IncSearch",
    })

    local fixed_treewalker = {
      -- move_up = fix_treesitter_function(treewalker.move_up),
      -- move_in = fix_treesitter_function(treewalker.move_in),
      -- move_down = fix_treesitter_function(treewalker.move_down),
      -- move_out = fix_treesitter_function(treewalker.move_out),
      swap_up = fix_treesitter_function(treewalker.swap_up),
      swap_right = fix_treesitter_function(treewalker.swap_right),
      swap_down = fix_treesitter_function(treewalker.swap_down),
      swap_left = fix_treesitter_function(treewalker.swap_left),
    }

    local make_repeatable = require("dot-repeat").make_repeatable

    vim.keymap.set(
      "n",
      "<Leader>wk",
      make_repeatable("treewalker_swap_up", fixed_treewalker.swap_up),
      { expr = true, desc = "Treewalker: Swap up" }
    )
    vim.keymap.set(
      "n",
      "<Leader>wl",
      make_repeatable("treewalker_swap_right", fixed_treewalker.swap_right),
      { expr = true, desc = "Treewalker: Swap right" }
    )
    vim.keymap.set(
      "n",
      "<Leader>wj",
      make_repeatable("treewalker_swap_down", fixed_treewalker.swap_down),
      { expr = true, desc = "Treewalker: Swap down" }
    )
    vim.keymap.set(
      "n",
      "<Leader>wh",
      make_repeatable("treewalker_swap_left", fixed_treewalker.swap_left),
      { expr = true, desc = "Treewalker: Swap left" }
    )
  end,
})
