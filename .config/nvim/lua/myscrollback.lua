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
