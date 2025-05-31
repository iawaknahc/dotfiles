require("lz.n").load({
  "flash.nvim",
  enabled = true,
  event = { "DeferredUIEnter" },
  after = function()
    require("flash").setup({
      search = {
        multi_window = false,
      },
      label = {
        rainbow = {
          enabled = true,
        },
      },
      modes = {
        char = {
          enabled = false,
        },
      },
    })

    vim.keymap.set({ "n", "x", "o" }, "s", function()
      require("flash").jump()
    end, { desc = "Flash" })
    vim.keymap.set({ "n", "x", "o" }, "S", function()
      require("flash").treesitter()
    end, { desc = "Flash Treesitter" })
  end,
})
