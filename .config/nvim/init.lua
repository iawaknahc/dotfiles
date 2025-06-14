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
-- We cannot map <Enter> to <Nop>, otherwise <Enter> will not work in quickfix list.
vim.keymap.set({ "n", "x" }, "s", "<Nop>") -- Disable :h s
vim.keymap.set({ "n", "x" }, "S", "<Nop>") -- Disable :h S
vim.keymap.set("n", "<C-l>", "<Cmd>set hlsearch!<Bar>diffupdate<Bar>normal! <C-L><CR>", {
  desc = ":h CTRL-L-default with nohlsearch changed to hlsearch!",
})
-- Inspired by gd
vim.keymap.set({ "n" }, "gD", vim.lsp.buf.declaration, {
  desc = "Go to declaration",
})
-- Inspired by Helix goto mode y
vim.keymap.set({ "n" }, "gy", vim.lsp.buf.type_definition, {
  desc = "Go to type definition",
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
vim.keymap.set({ "i", "c" }, [[<C-\><C-p>]], "<C-r>=getcwd()<CR>", {
  desc = "Insert getcwd()",
})
vim.keymap.set({ "i", "c" }, [[<C-\><C-a>]], [[<C-r>=expand("%:p")<CR>]], {
  desc = "Insert absolute path to current file",
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
