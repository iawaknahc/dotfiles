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
vim.api.nvim_create_autocmd("LspAttach", {
  group = lspGroup,
  callback = function(args)
    local bufnr = args.buf

    local map_opts = { noremap = true, buffer = bufnr }
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, map_opts)
    vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition, map_opts)
    vim.keymap.set('n', 'g?', vim.diagnostic.open_float, map_opts)
    vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, map_opts)
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
    vim.bo[bufnr].fixendofline = true
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

vim.o.completeopt = 'menu,menuone,noselect'
