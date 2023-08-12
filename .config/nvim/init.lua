-- load .vimrc
vim.cmd [[
" :help nvim-from-vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
]]


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
  callback = function() vim.highlight.on_yank() end,
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
vim.keymap.set('n', 'g?', vim.diagnostic.open_float, { noremap = true })


-- Set up lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")
