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
