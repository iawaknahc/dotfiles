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

-- Mapping
vim.keymap.set("n", "<Space>", "<Nop>") -- Disable :h <Space>
vim.keymap.set({ "n", "x" }, "s", "<Nop>") -- Disable :h s
vim.keymap.set({ "n", "x" }, "S", "<Nop>") -- Disable :h S
vim.keymap.set("n", "<C-l>", "<Cmd>set hlsearch!<Bar>diffupdate<Bar>normal! <C-L><CR>", {
  desc = ":h CTRL-L-default with nohlsearch changed to hlsearch!",
})
vim.keymap.set({ "i", "c" }, [[<C-\><C-p>]], "<C-r>=getcwd()<CR>", {
  desc = "Insert getcwd()",
})
vim.keymap.set({ "i", "c" }, [[<C-\><C-a>]], [[<C-r>=expand("%:p")<CR>]], {
  desc = "Insert absolute path to current file",
})
vim.keymap.set({ "n", "x", "o" }, "n", "'Nn'[v:searchforward]", {
  desc = "Make n always search forward",
  expr = true,
})
vim.keymap.set({ "n", "x", "o" }, "N", "'nN'[v:searchforward]", {
  desc = "Make N always search backward",
  expr = true,
})

-- Inspired by gd
vim.keymap.set({ "n" }, "gD", vim.lsp.buf.declaration, {
  desc = "Go to declaration",
})
-- Inspired by Helix goto mode y
vim.keymap.set({ "n" }, "gy", vim.lsp.buf.type_definition, {
  desc = "Go to type definition",
})
-- Inspired by Helix space mode d
vim.keymap.set("n", "<Space>d", function()
  vim.diagnostic.setloclist()
end, {
  desc = ":lua vim.diagnostic.setloclist()",
})
-- After trying inlay hint for some time,
-- I found it quite annoying.
-- So do not enable it initially.
vim.keymap.set({ "n" }, "grh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
    bufnr = 0,
  }), {
    bufnr = 0,
  })
end, {
  desc = "Toggle inlay hints",
})
vim.keymap.set("n", "gf", function()
  -- I found that both vim and neovim does not handle the case that
  -- the file under cursor does not exist yet.
  --
  -- In :help gf, it is suggested that you can
  -- :map gf :edit <cfile><CR>
  -- But that does not seem to handle path like ../.foo/bar

  local file_under_cursor = vim.fn.expand("<cfile>")

  -- Absolute path
  if vim.startswith(file_under_cursor, "/") then
    -- Fallback to original gf.
    vim.cmd([[normal! gf]])
    return
  end

  -- Otherwise we construct a path relative to the current file.
  local parent_directory = vim.fn.expand("%:h")
  local path = vim.fs.joinpath(parent_directory, file_under_cursor)
  local normalized = vim.fs.normalize(path)
  local fname = vim.fn.fnameescape(normalized)
  vim.cmd([[edit ]] .. fname)
end, {
  desc = "Edit file under cursor",
})
vim.keymap.set({ "n" }, "gx", function()
  local function gx()
    local word = vim.fn.expand("<cfile>")
    vim.ui.open(word)
  end

  --- @return vim.lsp.Client|nil
  local function get_gopls()
    local clients = vim.lsp.get_clients({
      name = "gopls",
      method = "textDocument/documentLink",
    })
    if #clients == 0 then
      return nil
    end
    return clients[1]
  end

  --- @param document_link lsp.DocumentLink
  --- @return boolean
  local function is_package_documentation_link(document_link)
    local target = document_link.target
    if target == nil then
      return false
    end
    if vim.startswith(target, "https://pkg.go.dev/") then
      return true
    end
    return false
  end

  ---@param pos lsp.Position
  ---@param range lsp.Range
  ---@return boolean
  local function is_in_range(pos, range)
    if pos.line > range.start.line and pos.line < range["end"].line then
      return true
    elseif pos.line == range.start.line and pos.line == range["end"].line then
      return pos.character >= range.start.character and pos.character <= range["end"].character
    elseif pos.line == range.start.line then
      return pos.character >= range.start.character
    elseif pos.line == range["end"].line then
      return pos.character <= range["end"].character
    else
      return false
    end
  end

  local gopls = get_gopls()
  if gopls == nil then
    gx()
    return
  end

  gopls:request(
    "textDocument/documentLink",
    vim.lsp.util.make_position_params(0, "utf-8"),
    function(err, result, context, _config)
      if err == nil then
        --- @type lsp.Position
        local cursor_position = context.params.position

        for _, item in ipairs(result) do
          --- @type lsp.DocumentLink
          local document_link = item
          local range = document_link.range
          if is_package_documentation_link(document_link) then
            if is_in_range(cursor_position, range) then
              vim.ui.open(document_link.target)
              return
            end
          end
        end
      end

      gx()
    end
  )
end, {
  desc = "Open link under cursor",
})
vim.keymap.set("i", "<C-s>", function()
  vim.lsp.buf.signature_help({
    focusable = false,
    anchor_bias = "above",
    max_height = 30,
    max_width = 80,
  })
end, {
  desc = "vim.lsp.buf.signature_help()",
})
vim.keymap.set("n", "g8", function()
  require("g8").g8()
end, {
  desc = "Unicode: Print byte sequence in 'fileencoding'",
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

-- Use neovim to display terminal scrollback.
-- See https://github.com/neovim/neovim/issues/30415
-- See https://github.com/folke/dot/blob/39602b7edc7222213bce762080d8f46352167434/nvim/lua/util/init.lua#L68-L93
vim.api.nvim_create_user_command("Scrollback", function()
  local win = 0
  -- Disable most UI elements to make the it look like a native terminal scrollback.
  vim.wo.foldcolumn = "0"
  vim.wo.signcolumn = "no"
  vim.wo.number = false
  vim.wo.statusline = ""

  local original_buf = vim.api.nvim_win_get_buf(win)
  -- tmux capture-pane gives us some blank lines at the end of the file.
  -- Remove them.
  vim.cmd([[
    call deletebufline('%', prevnonblank('$') + 1, '$')
  ]])

  -- Create a :terminal to parse the escape sequence.
  -- This is how we support colors.
  local term_buf = vim.api.nvim_create_buf(true, true)
  local chan = vim.api.nvim_open_term(term_buf, {})
  vim.api.nvim_chan_send(chan, table.concat(vim.api.nvim_buf_get_lines(original_buf, 0, -1, false), "\n"))

  -- Display the terminal buffer in the current window.
  vim.api.nvim_win_set_buf(win, term_buf)
  -- Remove the original buffer, we do not need it anymore.
  vim.api.nvim_buf_delete(original_buf, {
    force = true,
    unload = false,
  })

  -- quit with q, like in less.
  vim.keymap.set("n", "q", "<Cmd>q!<CR>")

  -- The terminal is not connected to a running process by default.
  -- So entering Insert mode does not really do anything useful.
  -- TODO(pager): But entering Insert mode will move the cursor to the end of the buffer. How can we prevent that?
  vim.api.nvim_create_autocmd("TermEnter", { buffer = term_buf, command = "stopinsert" })
  -- As the terminal processes the text, we keep moving the cursor.
  vim.api.nvim_create_autocmd("TextChanged", {
    buffer = term_buf,
    callback = function()
      vim.cmd("normal! " .. vim.fn.prevnonblank("$") .. "g$")
    end,
  })
end, {
  nargs = 0,
})

vim.api.nvim_create_user_command("CloseFloatingWindows", function()
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then -- is floating window
      local force = false
      vim.api.nvim_win_close(win, force)
    end
  end
end, {
  nargs = 0,
})
-- Override :h i_CTRL-Q
vim.keymap.set("i", "<C-q>", "<Cmd>CloseFloatingWindows<CR>", {
  desc = ":CloseFloatingWindows",
})

vim.api.nvim_create_user_command("ClearAllRegisters", function()
  -- . and : are not allowed to be cleared in this way.
  local all_registers = [[abcdefghijklmnopqrstuvwxyz0123456789*+-/=_"]]
  for _, register in ipairs(vim.split(all_registers, "")) do
    vim.fn.setreg(register, "")
  end

  ---@type string|nil
  local shada_setting_register = nil
  local shada_settings = vim.split(vim.o.shada, ",")
  for _, shada_setting in ipairs(shada_settings) do
    if string.sub(shada_setting, 1, 1) == "<" then
      shada_setting_register = shada_setting
    end
  end

  if shada_setting_register ~= nil then
    vim.opt.shada:remove({ shada_setting_register })
    vim.cmd([[wshada!]])
    vim.opt.shada:append({ shada_setting_register })
  end

  if shada_setting_register ~= nil then
    vim.notify(string.format("Cleared registers %s from ShaDa", all_registers))
  else
    vim.notify(string.format("Cleared registers %s", all_registers))
  end
end, {
  nargs = 0,
})

vim.api.nvim_create_user_command("Lvimgrep", function(args)
  local pattern = args.args

  -- https://github.com/neovim/neovim/pull/34215
  ---@diagnostic disable-next-line: redundant-parameter
  local original_pattern = vim.fn.getreg("/", 1, false)
  local win = vim.fn.winnr()

  if pattern ~= "" then
    vim.fn.setreg("/", pattern)
  elseif original_pattern == "" then
    vim.notify("No last pattern", vim.log.levels.WARN)
    return
  end

  vim.o.hlsearch = true
  local ok = pcall(function()
    vim.cmd([[lvimgrep //gj %]])
  end)
  if not ok then
    vim.notify("No matches", vim.log.levels.WARN)
  else
    -- TODO: select the selected entry to the closest cursor position.
    vim.schedule(function()
      vim.cmd(win .. [[wincmd w]])
    end)
  end
end, {
  desc = "/ to loclist",
  nargs = "*",
})
vim.keymap.set("n", "<M-/>", ":Lvimgrep<Space>", {
  desc = "/ to loclist",
})

vim.api.nvim_create_user_command("Reverse", function(args)
  local line1 = args.line1
  local line2 = args.line2
  local command = string.format("%d,%dglobal/^/move %d", line1, line2, line1 - 1)
  vim.cmd(command)
  vim.notify(command)
end, {
  desc = "Reverse line order as in :help 12.4",
  range = "%",
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

local myautocmd_group = vim.api.nvim_create_augroup("MyAutocmd", { clear = true })

-- Copied from the example given in :h vim.treesitter.start()
-- We actually do not need the API of nvim-treesitter to do highlight.
-- We DO need the data (RUNTIME/queries) installed by nvim-treesitter though.
vim.api.nvim_create_autocmd("FileType", {
  group = myautocmd_group,
  pattern = "*",
  callback = function(ev)
    local buf = ev.buf
    local filetype = ev.match

    local max_filesize = 100 * 1024 -- 100KiB
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats ~= nil and stats.size > max_filesize then
      return
    end

    -- Try twice.
    -- Some special buffer like :h checkhealth only work with vim.treesitter.start(buf)
    local ok_with_ft, _err_with_ft = pcall(vim.treesitter.start, buf, filetype)
    if not ok_with_ft then
      local _ok_without_ft, _err_without_ft = pcall(vim.treesitter.start, buf)
    end
  end,
})

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
myautocmd_set_filetype("docker-compose.yaml", "yaml.docker-compose")
myautocmd_set_filetype("docker-compose.yml", "yaml.docker-compose")

vim.api.nvim_create_autocmd("TextYankPost", {
  group = myautocmd_group,
  pattern = "*",
  callback = function()
    vim.hl.on_yank({
      timeout = 250,
    })
  end,
})

-- Disable inlay hint when entering insert mode.
vim.api.nvim_create_autocmd("InsertEnter", {
  group = myautocmd_group,
  callback = function(args)
    local bufnr = args.buf

    vim.b.inlay_hint_is_enabled = vim.lsp.inlay_hint.is_enabled({
      bufnr = bufnr,
    })

    vim.lsp.inlay_hint.enable(false, {
      bufnr = bufnr,
    })
  end,
})

-- Restore inlay hint when leaving insert mode.
vim.api.nvim_create_autocmd("InsertLeave", {
  group = myautocmd_group,
  callback = function(args)
    local bufnr = args.buf

    local is_enabled = vim.b.inlay_hint_is_enabled
    if is_enabled ~= nil then
      vim.lsp.inlay_hint.enable(is_enabled, {
        bufnr = bufnr,
      })
    end
  end,
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = myautocmd_group,
  pattern = "*",
  desc = "Track diagnostic count",
  callback = vim.schedule_wrap(function(args)
    if not vim.api.nvim_buf_is_valid(args.buf) then
      vim.b.diagnostic_count = nil
      return
    end

    local out = {
      [vim.diagnostic.severity.ERROR] = 0,
      [vim.diagnostic.severity.WARN] = 0,
      [vim.diagnostic.severity.INFO] = 0,
      [vim.diagnostic.severity.HINT] = 0,
    }
    for _, d in ipairs(vim.diagnostic.get(args.buf)) do
      out[d.severity] = out[d.severity] + 1
    end

    vim.b.diagnostic_count = out

    vim.cmd([[redrawstatus]])
  end),
})

-- Helper functions

---@param rfc3339 string
---@return integer?
function _G.rfc3339_to_unix(rfc3339)
  local bak = vim.fn.getreginfo("a")
  vim.fn.setreg("a", rfc3339)
  vim.cmd([[python << EOF
import math
import vim
from datetime import datetime
rfc3339 = vim.eval("@a")
dt = datetime.fromisoformat(rfc3339)
unix = str(math.floor(dt.timestamp()))
vim.command("let @a=" + unix)
EOF
]])

  -- https://github.com/neovim/neovim/pull/34215
  ---@diagnostic disable-next-line: redundant-parameter
  local result = vim.fn.getreg("a", 1, false)
  vim.fn.setreg("a", bak)
  return tonumber(result)
end

---@param unix integer
---@return string
function _G.unix_to_rfc3339(unix)
  local bak = vim.fn.getreginfo("a")
  vim.fn.setreg("a", tostring(unix))
  vim.cmd([[python << EOF
from datetime import datetime, timezone
unix = int(vim.eval("@a"))
dt = datetime.fromtimestamp(unix, timezone.utc)
formatted = dt.isoformat().replace("+00:00", "Z")
vim.command("let @a=" + repr(formatted))
EOF
]])

  -- https://github.com/neovim/neovim/pull/34215
  ---@diagnostic disable-next-line: redundant-parameter
  local result = vim.fn.getreg("a", 1, false) --[[@as string]]
  vim.fn.setreg("a", bak)
  return result
end

-- Some treesitter plugins assume that parser:parse() has been called once.
-- This may not be true if I do not have another plugin doing that.
-- So we make this wrapper function to wrap any problematic plugin function.
--
---@param fn function
---@return function
function _G.fix_treesitter_function(fn)
  return function(...)
    local ok, parser = pcall(vim.treesitter.get_parser)
    if ok and parser ~= nil then
      parser:parse(true)
    end
    fn(...)
  end
end

-- Terminal-mode

local myterminal_autocmdgroup = vim.api.nvim_create_augroup("MyTerminal", { clear = true })

-- Press <Esc> to exit terminal-mode
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], {
  desc = "<Esc> in terminal mode",
})

-- :lcd with OSC 7
vim.api.nvim_create_autocmd({ "TermRequest" }, {
  group = myterminal_autocmdgroup,
  desc = ":lcd with OSC 7",
  callback = function(ev)
    if string.sub(ev.data.sequence, 1, 4) == "\x1b]7;" then
      local dir = string.gsub(ev.data.sequence, "\x1b]7;file://[^/]*", "")
      if vim.fn.isdirectory(dir) == 0 then
        vim.notify("invalid dir: " .. dir, vim.log.levels.WARN)
        return
      end
      vim.api.nvim_buf_set_var(ev.buf, "osc7_dir", dir)
      if vim.api.nvim_get_current_buf() == ev.buf then
        vim.cmd.lcd(dir)
      end
    end
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "DirChanged" }, {
  group = myterminal_autocmdgroup,
  callback = function()
    if vim.b.osc7_dir and vim.fn.isdirectory(vim.b.osc7_dir) == 1 then
      vim.cmd.lcd(vim.b.osc7_dir)
    end
  end,
})

-- Enter insert mode when a terminal is opened.
vim.api.nvim_create_autocmd("TermOpen", {
  group = myterminal_autocmdgroup,
  pattern = "*",
  command = "startinsert",
})

-- :Terminal is like :terminal, except than it does not use 'shell' but "$SHELL", when
-- invoked without an argument.
vim.api.nvim_create_user_command("Terminal", function(args)
  if #args.fargs == 0 then
    vim.cmd(args.mods .. " " .. "terminal " .. vim.fn.expand("$SHELL"))
  else
    vim.cmd(args.mods .. " " .. "terminal " .. args.args)
  end
end, {
  nargs = "*",
  complete = "shellcmdline",
})
-- We do not check getcmdline() because it is likely that the cmdline has modifiers.
-- In case you want to type "Terminal", you use :h c_CTRL-V to type <Space> character.
vim.cmd([[
cnoreabbrev <expr> ter      (getcmdtype() ==# ':') ? 'Ter'      : 'ter'
cnoreabbrev <expr> term     (getcmdtype() ==# ':') ? 'Term'     : 'term'
cnoreabbrev <expr> termi    (getcmdtype() ==# ':') ? 'Termi'    : 'termi'
cnoreabbrev <expr> termin   (getcmdtype() ==# ':') ? 'Termin'   : 'termin'
cnoreabbrev <expr> termina  (getcmdtype() ==# ':') ? 'Termina'  : 'termina'
cnoreabbrev <expr> terminal (getcmdtype() ==# ':') ? 'Terminal' : 'terminal'
]])
