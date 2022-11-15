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

local lspGroup = vim.api.nvim_create_augroup("LSPAutoCommands", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = lspGroup,
  callback = function()
    vim.lsp.buf.format({
      async = false,
      timeout_ms = 1000,
    })
  end,
})
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = lspGroup,
  callback = function()
    vim.diagnostic.setloclist({ open = false })
  end,
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
