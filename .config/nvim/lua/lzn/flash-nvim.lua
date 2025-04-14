require("lz.n").load({
  "flash.nvim",
  event = { "DeferredUIEnter" },
  keys = {
    {
      "s",
      function()
        require("flash").jump()
      end,
      mode = { "n" },
      desc = "Flash",
    },
  },
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
  end,
})
