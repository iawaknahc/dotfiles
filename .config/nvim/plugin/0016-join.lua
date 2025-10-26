vim.api.nvim_create_user_command("Join", function(opts)
  local bufnr = 0
  local win = 0

  local delimiter = opts.args
  -- Work like :join
  if delimiter == "" then
    delimiter = " "
  end
  -- If it looks like a Vimscript string literal, parse it as such.
  if vim.startswith(delimiter, "'") or vim.startswith(delimiter, '"') then
    delimiter = vim.api.nvim_eval(opts.args)
  end

  local start_line1 = opts.line1
  local end_line1 = opts.line2
  -- Work like :join
  if end_line1 == start_line1 then
    end_line1 = start_line1 + 1
  end

  -- This fails when we join at the last line.
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, start_line1 - 1, end_line1, true)
  if not ok then
    return
  end

  -- Except the first line, trim the spaces.
  for i, line in ipairs(lines) do
    if i ~= 1 then
      lines[i] = vim.trim(line)
    end
  end

  local joined = table.concat(lines, delimiter)

  vim.api.nvim_buf_set_lines(bufnr, start_line1 - 1, end_line1, true, { joined })

  -- The behavior of :join is to place the cursor before the last joined line.
  -- That is not trivial to implement so we always move the cursor to the end.
  vim.api.nvim_win_set_cursor(win, { start_line1, #joined })
end, {
  nargs = "?",
  range = true,
  desc = ":join with custom delimiter",
})
