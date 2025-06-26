require("lz.n").load({
  "flash.nvim",
  enabled = true,
  event = { "DeferredUIEnter" },
  after = function()
    local flash = require("flash")

    flash.setup({
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

    local flash_treesitter = _G.fix_treesitter_function(flash.treesitter)

    vim.keymap.set({ "n", "x", "o" }, "s", function()
      flash.jump()
    end, { desc = "Flash" })
    vim.keymap.set({ "n", "x", "o" }, "S", function()
      flash_treesitter()
    end, { desc = "Flash Treesitter" })
  end,
})
