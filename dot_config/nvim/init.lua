-- moonwalk and fennel
require("moonwalk").add_loader("fnl", function(src)
  return require("fennel").compileString(src)
end)

require("myconfig")

-- Set up lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.runtimepath:prepend(lazypath)
require("lazy").setup({
  -- See https://lazy.folke.io/usage/structuring
  spec = {
    { import = "plugins" },
  },
  defaults = {
    -- lazy by default.
    lazy = true,
  },

  -- I used to enable auto check for update.
  -- But this will cause lazy to write :messages on every launch,
  -- consuming some of my keystrokes.
  -- This is quite annoying.
  -- checker = {
  --   enabled = true,
  -- },

  -- Do not detect change when I am editing plugin configs.
  change_detection = {
    enabled = false,
  },

  -- I do not use Nerd Font.
  ui = {
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})
