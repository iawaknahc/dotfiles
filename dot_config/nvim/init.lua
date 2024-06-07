-- The default is :filetype detection:ON plugin:ON indent:ON
-- We want to turn off indent.
vim.cmd.filetype("indent", "off")

-- Security
-- https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md
vim.o.modeline = false

-- Look
vim.o.signcolumn = "yes"
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

-- colorcolumn
local colorcolumn = {}
for i = 1, 100 do
  table.insert(colorcolumn, "+" .. i)
end
vim.opt.colorcolumn = colorcolumn

-- Completion
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Command completion
vim.opt.wildmode = { "longest:full", "full" }

-- Editing
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.scrolloff = 5
vim.o.foldenable = false
vim.opt.clipboard:append({ "unnamed" })
vim.o.fixendofline = false

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Mapping
vim.g.mapleader = " "
vim.keymap.set("n", "<Leader><Space>", ":set hlsearch!<CR>", { remap = false })

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
-- By default, filetype.vim treats *.env as sh
-- We do NOT want to run any before-save fix on *.env
-- For example, some envvars may have trailing whitespaces we do want to preserve.
local dotEnvGroup = vim.api.nvim_create_augroup("MyDotEnv", { clear = true })
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = "*.env",
  callback = function()
    vim.bo.filetype = ""
  end,
  group = dotEnvGroup,
})

local spellCheckGroup = vim.api.nvim_create_augroup("MySpellCheck", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "text" , "markdown" },
  callback = function()
    vim.wo.spell = true
    vim.bo.spelllang = "en_us"
  end,
  group = spellCheckGroup,
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
