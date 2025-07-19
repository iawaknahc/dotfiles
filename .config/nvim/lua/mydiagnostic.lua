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

local mydiagnostic_autocmdgroup = vim.api.nvim_create_augroup("MyDiagnostic", { clear = true })

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = mydiagnostic_autocmdgroup,
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
