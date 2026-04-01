local mydiagnostic_autocmdgroup = vim.api.nvim_create_augroup("MyDiagnostic", { clear = true })

-- Avoid require("vim.diagnostic") in startup.
vim.api.nvim_create_autocmd("VimEnter", {
  group = mydiagnostic_autocmdgroup,
  callback = function()
    local signs = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    }
    local hl_map = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticError",
      [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticHint",
    }

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
      status = {
        format = function(counts)
          local items = {}
          for level, _ in ipairs(vim.diagnostic.severity) do
            local count = counts[level] or 0
            -- Do not include 0
            if count > 0 then
              table.insert(items, ("%%#%s#%s %s"):format(hl_map[level], signs[level], count))
            end
          end
          -- Return empty string if there are no diagnostic items.
          if #items == 0 then
            return ""
          end
          return table.concat(items, " ")
        end,
      },
    })
  end,
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = mydiagnostic_autocmdgroup,
  pattern = "*",
  desc = "Redraw statusline",
  callback = vim.schedule_wrap(function()
    vim.cmd([[redrawstatus]])
  end),
})

-- Inspired by Helix space mode d
vim.keymap.set("n", "<Space>d", function()
  vim.diagnostic.setloclist()
end, {
  desc = ":lua vim.diagnostic.setloclist()",
})
