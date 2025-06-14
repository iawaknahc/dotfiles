require("lz.n").load({
  "oil.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  lazy = false,
  after = function()
    require("oil").setup({
      columns = {},
      keymaps = {
        ["<Leader><Leader>"] = {
          function()
            local oil = require("oil")
            if vim.b.oil_columns == nil then
              vim.b.oil_columns = { "icon", "permissions", "size", "mtime" }
              oil.set_columns(vim.b.oil_columns)
            else
              vim.b.oil_columns = nil
              oil.set_columns({})
            end
          end,
          mode = "n",
          desc = "Oil: toggle columns",
        },
      },
    })

    vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Oil: Open directory" })
  end,
})
