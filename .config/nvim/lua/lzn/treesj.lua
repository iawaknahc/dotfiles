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

    vim.keymap.set("n", "<Leader>s", function()
      treesj.split()
    end, {
      desc = "TreeSJ: Split node",
    })

    vim.keymap.set("n", "<Leader>j", function()
      treesj.join()
    end, {
      desc = "TreeSJ: Join node",
    })
  end,
})
