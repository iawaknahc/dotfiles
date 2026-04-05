-- The default is :filetype detection:ON plugin:ON indent:ON
-- We want to turn off indent.
vim.cmd([[filetype indent off]])

-- Hardening
-- VIM / Neovim has a track record of vulnerable modeline.
-- See https://www.cve.org/CVERecord?id=CVE-2016-1248
-- See https://www.cve.org/CVERecord?id=CVE-2019-12735
vim.go.modeline = false
vim.go.modelines = 0

-- colorscheme
vim.cmd([[colorscheme catppuccin-mocha]])

-- statuscolumn
vim.go.foldcolumn = "1"
-- We use statuscol.nvim to customize the whole statuscolumn.
-- The value of 'signcolumn' is unimportant here.
vim.go.signcolumn = "auto:1-9"
-- The default is 4.
vim.go.numberwidth = 1
vim.go.number = true

-- Display of whitespaces.
vim.go.list = true
-- leadmultispace is powerful enough. I do not need https://github.com/lukas-reineke/indent-blankline.nvim now.
-- https://www.reddit.com/r/neovim/comments/17aponn/i_feel_like_leadmultispace_deserves_more_attention/
-- leadtab was added in 0.12.
-- leadtab:xyz means x is always used, z is always used, y is repeated.
-- This implies tab: must be configured in a way to align with leadtab.
-- Therefore, we have to use tab:xyz form.
--
-- Spaces should be shown as dot.
-- Therefore, leadmultispace, lead, and trail uses dot.
-- Tabs should be shown as multiple hyphens plus a greater-than sign tail so that it is visually different from spaces.
-- Non-breaking spaces should be visually different from spaces and tabs, so we take the default from neovim, the plus sign.
vim.opt.listchars = {
  leadmultispace = "▏.",
  leadtab = "▏->",
  lead = ".",
  tab = "-->",
  trail = ".",
  nbsp = "+",
}

vim.go.breakindent = true

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
vim.go.cursorlineopt = "number"
vim.go.cursorline = true

-- floating window
vim.go.winborder = "rounded"

-- Completion
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.go.pumheight = 10
-- The completion menu of common completion plugins (e.g. blink.cmp) has a default height of 10.
-- We set scrolloff to 15 so that we can see the completion menu plus a context of 5 lines.
-- Note that scrolloff does not work at the end of the buffer.
-- See https://github.com/vim/vim/issues/13428
-- There is a plugin https://github.com/Aasim-A/scrollEOF.nvim
-- I tried that plugin but that plugin will interfere other plugins that create it own filetype, such as fzf-lua.
-- It is just too cumbersome to exclude those plugin-private filetypes.
vim.go.scrolloff = 15

-- Command mode
-- shell by default is $SHELL.
-- But I do not want neovim to run command with fish.
vim.go.shell = "sh"
-- On the first use of c_<Tab>, complete til the longest common string AND show the completion menu WITHOUT selecting the first item.
-- On subsequent use of c_<Tab>, select the next item in the completion menu.
vim.opt.wildmode = { "longest:noselect", "full" }

-- Editing
vim.go.backup = false
vim.go.writebackup = false
vim.go.swapfile = false
-- This controls how often the swapfile is written.
-- This also controls how often vim-gitgutter updates the signs.
-- :h updatetime
vim.go.updatetime = 100

-- clipboard
vim.opt.clipboard:append({ "unnamed" })

-- Keep the original endofline convention of the file.
vim.go.fixendofline = false

-- No need to make ~ an operator.
-- Its operator version is :h g~

-- Fold
-- foldmethod is not set here because it depends on filetype.
vim.go.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.go.foldlevelstart = 99

-- Search
vim.go.ignorecase = true
vim.go.smartcase = true
vim.go.wrapscan = false

-- grep
vim.go.grepprg = "rg --vimgrep"

-- diff
vim.opt.diffopt = {
  "internal",
  "indent-heuristic",
  "algorithm:histogram",
  "closeoff",
  "filler",
  "foldcolumn:1",
  "linematch:60",
  "inline:word",
}

-- session
vim.go.sessionoptions = "blank,buffers,curdir,help,tabpages,terminal,winsize"
