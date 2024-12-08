-- moonwalk and fennel
require("moonwalk").add_loader("fnl", function(src)
  return require("fennel").compileString(src)
end)

-- The default is :filetype detection:ON plugin:ON indent:ON
-- We want to turn off indent.
vim.cmd.filetype("indent", "off")

-- Legacy syntax is turned on by default (:h nvim-defaults).
-- We want to turn it off here.
-- If we run :scriptnames, we see synload.vim is still sourced.
-- This is probably due to this trick.
-- https://github.com/neovim/neovim/blob/v0.10.1/runtime/lua/vim/treesitter/highlighter.lua#L138
vim.cmd.syntax("off")

-- Security
-- https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md
vim.o.modeline = false

-- Look
-- Always reserve 1 column for vim-gitgutter and 2 columns for vim.diagnostic
vim.o.signcolumn = "auto:3-9"
-- The default is 4.
vim.o.numberwidth = 1
vim.o.number = true
vim.o.list = true
-- lead:. is taken from the help of neovim.
-- trail:- is the default of neovim.
-- nbsp:+ is the default of neovim.
-- tab:>  is the default of neovim. We change it to tab:>_ so that
-- the space is visible and distinguishable from leading spaces.
vim.opt.listchars = {
  tab = ">_",
  lead = ".",
  trail = "-",
  nbsp = "+",
}
vim.o.breakindent = true
vim.cmd.colorscheme("mydracula")

-- colorcolumn
local colorcolumn = {}
for i = 1, 100 do
  table.insert(colorcolumn, "+" .. i)
end
vim.opt.colorcolumn = colorcolumn

-- Completion
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.o.pumheight = 10

-- Command mode
-- shell by default is $SHELL.
-- But I do not want neovim to run command with fish.
vim.o.shell = "sh"
vim.opt.wildmode = { "longest:full", "full" }

-- Editing
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
-- This controls how often the swapfile is written.
-- This also controls how often vim-gitgutter updates the signs.
-- :h updatetime
vim.o.updatetime = 100
vim.o.scrolloff = 5
vim.o.foldenable = false
vim.opt.clipboard:append({ "unnamed" })
vim.o.fixendofline = false
-- Make ~ an operator
vim.o.tildeop = true

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wrapscan = false

-- Mapping
vim.keymap.set("n", "<Space>", "<Nop>", { desc = "Disable :h <Space>" })
vim.keymap.set("n", "gh", "<Nop>", { desc = "Disable :h gh" })
vim.keymap.set("n", "gH", "<Nop>", { desc = "Disable :h gH" })
vim.keymap.set("n", "g<C-h>", "<Nop>", { desc = "Disable :h g_CTRL-H" })
vim.keymap.set("n", "<C-l>", "<Cmd>set hlsearch!<Bar>diffupdate<Bar>normal! <C-L><CR>", {
  desc = ":h CTRL-L-default with nohlsearch changed to hlsearch!",
})

-- Command
vim.api.nvim_create_user_command("Space", function(t)
  local n = tonumber(t.fargs[1])
  if n ~= nil then
    vim.bo.tabstop = n
    vim.bo.shiftwidth = n
    vim.bo.softtabstop = n
    vim.bo.expandtab = true
  end
end, {
  nargs = 1,
})
vim.api.nvim_create_user_command("Tab", function(t)
  local n = tonumber(t.fargs[1])
  if n ~= nil then
    vim.bo.tabstop = n
    vim.bo.shiftwidth = n
    vim.bo.softtabstop = n
    vim.bo.expandtab = false
  end
end, {
  nargs = 1,
})
-- :HighlightGroupAtCursor prints out the highlight groups at cursor.
-- Useful for debugging colorscheme.
-- The motivation was to debug why @diff.plus has a different green color from the colorscheme.
vim.api.nvim_create_user_command("HighlightGroupAtCursor", function()
  print(vim.inspect(vim.treesitter.get_captures_at_cursor()))
end, {
  nargs = 0,
})

-- diagnostic
vim.diagnostic.config {
  virtual_text = {
    source = true,
  },
  float = {
    source = true,
  },
  severity_sort = true,
}

-- Set up autocommands
-- By default, filetype.vim treats *.env as sh
-- We do NOT want to run any before-save fix on *.env
-- For example, some envvars may have trailing whitespaces we do want to preserve.
local dotEnvGroup = vim.api.nvim_create_augroup("MyDotEnv", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.env",
  callback = function()
    vim.bo.filetype = ""
  end,
  group = dotEnvGroup,
})

local yankGroup = vim.api.nvim_create_augroup("MyYankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
  group = yankGroup,
})

local diagnosticGroup = vim.api.nvim_create_augroup("MyDiagnostic", { clear = true })
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = diagnosticGroup,
  callback = function()
    vim.diagnostic.setloclist({ open = false })
  end,
})

-- Key mappings
-- vim.diagnostic.open_float is mapped to <C-W>d since neovim 0.10.0

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
