local once = require("once")

local setup = once(function()
  vim.cmd([[packadd treesj]])

  require("treesj").setup({
    use_default_keymaps = false,
    max_join_length = 9999,
  })
  return nil
end)

-- This is no builtin CTRL-S keymap in normal mode, so we can take it.
vim.keymap.set("n", "<C-s>", function()
  setup()
  require("treesj").split()
end, { desc = "TreeSJ: Split node" })

-- :h CTRL-J is an alias of j, which can be taken by us.
vim.keymap.set("n", "<C-j>", function()
  setup()
  require("treesj").join()
end, { desc = "TreeSJ: Join node" })
