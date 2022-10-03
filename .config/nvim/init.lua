vim.cmd [[
" :help nvim-from-vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
]]

local yankGroup = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function() vim.highlight.on_yank() end,
  group = yankGroup,
})

require('plugins')

vim.diagnostic.config {
  virtual_text = {
    source = true,
  },
  float = {
    source = true,
  },
  severity_sort = true,
}
