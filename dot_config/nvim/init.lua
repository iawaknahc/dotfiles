-- load .vimrc
vim.cmd [[
" :help nvim-from-vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
]]

-- colorcolumn
local colorcolumn = {}
for i = 1, 100 do
  table.insert(colorcolumn, "+" .. i)
end
vim.wo.colorcolumn = table.concat(colorcolumn, ",")

-- Set nvim-specific options
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
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins", {
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
})
