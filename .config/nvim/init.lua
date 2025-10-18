-- The default is :filetype detection:ON plugin:ON indent:ON
-- We want to turn off indent.
vim.cmd.filetype("indent", "off")

-- Legacy syntax is turned on by default (:h nvim-defaults).
-- additional_vim_regex_highlighting=false will turn it off when treesitter highlight is available.
-- Legacy syntax is still useful when I do not install a treesitter parser for a given filetype, like man.
--
-- If we run :scriptnames, we see synload.vim is still sourced.
-- This is probably due to this trick.
-- https://github.com/neovim/neovim/blob/v0.10.1/runtime/lua/vim/treesitter/highlighter.lua#L138
-- vim.cmd.syntax("off")

-- Hardening
-- VIM / Neovim has a track record of vulnerable modeline.
-- See https://www.cve.org/CVERecord?id=CVE-2016-1248
-- See https://www.cve.org/CVERecord?id=CVE-2019-12735
vim.o.modeline = false
vim.o.modelines = 0

-- colorscheme
vim.cmd.colorscheme("catppuccin-mocha")

-- statuscolumn
vim.o.foldcolumn = "1"
-- We use statuscol.nvim to customize the whole statuscolumn.
-- The value of 'signcolumn' is unimportant here.
vim.o.signcolumn = "auto:1-9"
-- The default is 4.
vim.o.numberwidth = 1
vim.o.number = true

-- Display of whitespaces.
vim.o.list = true
-- lead:. is taken from the help of neovim.
-- trail:- is the default of neovim.
-- nbsp:+ is the default of neovim.
-- tab:>  is the default of neovim. We change the space to _ so that
-- the space is visible and distinguishable from leading spaces.
--
-- leadmultispace is powerful enough. I do not need https://github.com/lukas-reineke/indent-blankline.nvim now.
-- https://www.reddit.com/r/neovim/comments/17aponn/i_feel_like_leadmultispace_deserves_more_attention/
vim.opt.listchars = {
  leadmultispace = "▏.",
  lead = ".",
  tab = "▏_",
  trail = "-",
  nbsp = "+",
}

vim.o.breakindent = true

-- guicursor
--
-- | Mode | Shape      | Blink |
-- | ---  | ---        | ---   |
-- | n    | block      | no    |
-- | v    | block      | no    |
-- | sm   | block      | no    |
-- | i    | vertical   | yes   |
-- | c    | vertical   | no    |
-- | ci   | vertical   | no    |
-- | t    | vertical   | no    |
-- | r    | horizontal | yes   |
-- | cr   | horizontal | yes   |
-- | o    | horizontal | no    |
vim.opt.guicursor = {
  "a:blinkwait1000-blinkon100-blinkoff100",

  "n-v-sm:block-blinkon0",

  "i:ver25",

  "c-ci-t:ver25-blinkon0",

  "r-cr:hor20",
  "o:hor20-blinkon0",
}

-- cursorline
vim.o.cursorlineopt = "number"
vim.o.cursorline = true

-- floating window
vim.o.winborder = "rounded"

-- Completion
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.o.pumheight = 10
-- The completion menu of common completion plugins (e.g. blink.cmp) has a default height of 10.
-- We set scrolloff to 15 so that we can see the completion menu plus a context of 5 lines.
-- Note that scrolloff does not work at the end of the buffer.
-- See https://github.com/vim/vim/issues/13428
-- There is a plugin https://github.com/Aasim-A/scrollEOF.nvim
-- I tried that plugin but that plugin will interfere other plugins that create it own filetype, such as fzf-lua.
-- It is just too cumbersome to exclude those plugin-private filetypes.
vim.o.scrolloff = 15

-- Command mode
-- shell by default is $SHELL.
-- But I do not want neovim to run command with fish.
vim.o.shell = "sh"
-- On the first use of c_<Tab>, complete til the longest common string AND show the completion menu WITHOUT selecting the first item.
-- On subsequent use of c_<Tab>, select the next item in the completion menu.
vim.opt.wildmode = { "longest:noselect", "full" }

-- Editing
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
-- This controls how often the swapfile is written.
-- This also controls how often vim-gitgutter updates the signs.
-- :h updatetime
vim.o.updatetime = 100

-- clipboard
vim.opt.clipboard:append({ "unnamed" })

-- Keep the original endofline convention of the file.
vim.o.fixendofline = false

-- No need to make ~ an operator.
-- Its operator version is :h g~

-- Fold
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 99

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wrapscan = false

-- grep
vim.o.grepprg = "rg --vimgrep"

-- diff
vim.opt.diffopt = {
  "internal",
  "indent-heuristic",
  "algorithm:histogram",
  "closeoff",
  "filler",
  "foldcolumn:1",
  "linematch:60",
}

require("mycommand")
require("mydiagnostic")
require("myfiletype")
require("myfloatingwindow")
require("myhighlight")
require("mykeymap")
require("mylsp")
require("mynormal")
require("myregister")
require("myscrollback")
require("myterminal")
require("mytreesitter")
require("myvimgrep")

require("lzn.blink-cmp")
require("lzn.conform")
require("lzn.conjure")
require("lzn.dial-nvim")
require("lzn.diffview-nvim")
require("lzn.flash-nvim")
require("lzn.fzf-lua")
require("lzn.gitsigns-nvim")
require("lzn.mini-ai")
require("lzn.mini-clue")
require("lzn.mini-statusline")
require("lzn.mini-surround")
require("lzn.nvim-dap")
require("lzn.nvim-lint")
require("lzn.nvim-lspconfig")
require("lzn.nvim-notify")
require("lzn.nvim-pqf")
require("lzn.nvim-treesitter-context")
require("lzn.oil-nvim")
require("lzn.rainbow-delimiters")
require("lzn.statuscol-nvim")
require("lzn.treesj")
require("lzn.treewalker-nvim")
require("lzn.unicode-vim")
require("lzn.vim-caser")
require("lzn.vim-fugitive")
require("lzn.vim-rhubarb")
require("lzn.vim-sleuth")
require("lzn.vim-table-mode")
