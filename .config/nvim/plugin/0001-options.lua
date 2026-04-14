-- On 2026-04-05, I tried to migrate all vim.o to vim.go
-- The buffer I provide in argument does not seem to read from vim.go
-- For example, nvim main.go, then main.go has no number.
-- But nvim followed by :e main.go has number.
-- So stick with vim.o in this file.

-- The default is :filetype detection:ON plugin:ON indent:ON
-- We want to turn off indent.
vim.cmd([[filetype indent off]])

-- Hardening
-- VIM / Neovim has a track record of vulnerable modeline.
-- See https://www.cve.org/CVERecord?id=CVE-2016-1248
-- See https://www.cve.org/CVERecord?id=CVE-2019-12735
vim.o.modeline = false
vim.o.modelines = 0

-- colorscheme
vim.cmd([[colorscheme catppuccin-mocha]])

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
-- foldmethod is not set here because it depends on filetype.
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
  "inline:word",
}

-- session
vim.o.sessionoptions = "blank,buffers,curdir,help,tabpages,terminal,winsize"

-- We override vim.hl.priorities.semantic_tokens because we want to solve the following problem.
--
-- In a Nix file, `# TODO` is recognized as @lsp.type.comment.nix (which links to @comment) and @comment.todo.
-- The fg color of @comment.todo should have a higher priority than that of @lsp.type.comment.nix,
-- but since semantic tokens has higher priority, the normal fg color of comment is used instead.
-- This results in a very pale text color on a colored background, making the text very difficult to read.
--
-- Another approach of solving this is to override the priorities in queries/comment/highlights.scm
-- But that approach requires us to duplicate the whole file, effectively giving up upstream updates.
-- So we settle with a simpler approach of overriding vim.hl.priorities.semantic_tokens.
-- Most of the time, highlights come from treesitter, not LSP semantic tokens.
--
-- semantic_tokens is 125 originally.
-- We want to make it lower than treesitter (which is 100), and still higher than regex-based highlighting (which is 50).
-- (50 + 100) / 2 = 75
vim.hl.priorities.semantic_tokens = math.floor((vim.hl.priorities.syntax + vim.hl.priorities.treesitter) / 2)
