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

-- Security
-- https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md
vim.o.modeline = false

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

-- cursor
vim.opt.guicursor = {
  -- a has to come first, so that the blinking can be overridden by following lines.
  "a:blinkwait1000-blinkon100-blinkoff100",
  -- Do not blink in normal et al. modes.
  "n-v-c-sm:block-blinkon0",
  -- The number coming after ver or hor does not seem to have effect in the terminal.
  "i-ci-ve:ver25",
  "r-cr:hor20",
  "o:hor50",
  "t:ver25-TermCursor",
}

-- cursorline
vim.o.cursorlineopt = "number"
vim.o.cursorline = true

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

-- Auto scrolling
vim.o.scrolloff = 5

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

-- Mapping
vim.keymap.set("n", "<Space>", "<Nop>") -- Disable :h <Space>
-- We cannot map <Enter> to <Nop>, otherwise <Enter> will not work in quickfix list.
vim.keymap.set({ "n", "x" }, "s", "<Nop>") -- Disable :h s
vim.keymap.set({ "n", "x" }, "S", "<Nop>") -- Disable :h S
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
  local win = 0
  local buf = vim.api.nvim_win_get_buf(win)
  local row1, col0 = unpack(vim.api.nvim_win_get_cursor(win))
  local captures = vim.treesitter.get_captures_at_pos(buf, row1 - 1, col0)
  print(vim.inspect(captures))
end, {
  nargs = 0,
})

-- Diagnostic
vim.diagnostic.config({
  virtual_text = {
    source = true,
  },
  -- Turning on virtual_lines will cause virtual lines to be inserted.
  -- I do not like this.
  -- virtual_lines = true,
  float = {
    source = true,
  },
  severity_sort = true,
})

-- Autocmds

local myautocmd_group = vim.api.nvim_create_augroup("MyDotEnv", { clear = true })

local function myautocmd_set_filetype(pattern, filetype)
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = myautocmd_group,
    pattern = pattern,
    callback = function()
      vim.bo.filetype = filetype
    end,
  })
end

-- By default, filetype.vim treats *.env as sh
-- We do NOT want to run any before-save fix on *.env
-- For example, some envvars may have trailing whitespaces we do want to preserve.
myautocmd_set_filetype("*.env", "")
-- navi
myautocmd_set_filetype("*.cheat", "sh")
-- mjml
myautocmd_set_filetype("*.mjml", "html")

vim.api.nvim_create_autocmd("TextYankPost", {
  group = myautocmd_group,
  pattern = "*",
  callback = function()
    vim.hl.on_yank({
      timeout = 250,
    })
  end,
})
