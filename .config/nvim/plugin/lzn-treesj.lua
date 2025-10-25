require("lz.n").load({
  "treesj",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    local treesj = require("treesj")

    treesj.setup({
      use_default_keymaps = false,
      max_join_length = 9999,
    })

    -- This is no builtin CTRL-S keymap in normal mode, so we can take it.
    vim.keymap.set("n", "<C-s>", function()
      treesj.split()
    end, { desc = "TreeSJ: Split node" })

    -- :h CTRL-J is an alias of j, which can be taken by us.
    vim.keymap.set("n", "<C-j>", function()
      treesj.join()
    end, { desc = "TreeSJ: Join node" })
  end,
})
