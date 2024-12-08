-- moonwalk and fennel
require("moonwalk").add_loader("fnl", function(src)
  return require("fennel").compileString(src)
end)

require("myconfig")

-- Set up lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.runtimepath:prepend(lazypath)

local function get_extension(filename, ext)
  return filename:sub(-string.len(ext) - 1)
end

local function strip_extension(filename, ext)
  return filename:sub(1, -string.len(ext) - 2)
end

local specs = {}
for _, lang in ipairs({ "lua", "fnl" }) do
  local PLUGINS = "plugins"
  local paths = vim.fs.find(function(name)
    if get_extension(name, lang) == "." .. lang then
      return true
    end
    return false
  end, {
    path = vim.fs.joinpath(vim.fn.stdpath("config"), lang, PLUGINS),
    type = "file",
    limit = math.huge,
  })
  for _, path in ipairs(paths) do
    local basename = vim.fs.basename(path)
    local without_ext = strip_extension(basename, lang)
    local module_name = PLUGINS .. "." .. without_ext
    -- lazy.nvim does not know how to import non-lua module.
    -- So we do the import and pass them directly to lazy.nvim.
    local spec = require(module_name)
    table.insert(specs, spec)
  end
end

require("lazy").setup({
  -- See https://lazy.folke.io/usage/structuring
  spec = specs,
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
