local once = require("once")

local setup = once(
  ---@return fun()
  function()
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
    local fix_treesitter_function = require("fix_treesitter_function")
    local flash_treesitter = fix_treesitter_function(flash.treesitter)
    return flash_treesitter
  end
)

vim.keymap.set({ "n" }, "s", function()
  setup()
  require("flash").jump()
end, { desc = "Flash" })

-- nvim-surround has an S keymap in visual mode.
vim.keymap.set({ "n" }, "S", function()
  local flash_treesitter = setup()
  flash_treesitter()
end, { desc = "Flash Treesitter" })
