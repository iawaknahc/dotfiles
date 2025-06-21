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
      prompt = {
        win_config = {
          -- Since we set winborder="rounded", we need to make it appear like Cmd again.
          border = "none",
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
