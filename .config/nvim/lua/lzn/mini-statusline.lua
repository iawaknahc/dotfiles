require("lz.n").load({
  "mini.statusline",
  enabled = vim.g.pager_enabled ~= 1,
  lazy = false,
  after = function()
    local MiniStatusline = require("mini.statusline")

    local function get_bufnr(args)
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end

      local buf = vim.api.nvim_get_current_buf()
      return string.format("b%d", buf)
    end

    local function get_winnr(args)
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end

      local win = vim.api.nvim_get_current_win()
      return string.format("w%d", win)
    end

    local function get_filename(args)
      if vim.bo.buftype == "terminal" then
        return "%t"
      elseif MiniStatusline.is_truncated(args.trunc_width) then
        return "%t%m%r"
      else
        return "%f%m%r"
      end
    end

    local function get_filetype(args)
      local filetype = vim.bo.filetype
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end
      return filetype
    end

    local function get_fileencoding(args)
      local fileencoding = vim.bo.fileencoding
      if fileencoding ~= "utf-8" then
        return "%#ErrorMsg#" .. fileencoding
      end
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end
      return fileencoding
    end

    local function get_fileformat(args)
      local fileformat = vim.bo.fileformat
      if fileformat ~= "unix" then
        return "%#ErrorMsg#" .. fileformat
      end
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end
      return fileformat
    end

    local function get_endofline(args)
      local endofline = vim.bo.endofline
      if not endofline then
        return "%#ErrorMsg#" .. "NOEOL"
      end
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end
      return "eol"
    end

    local function get_filesize(args)
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end

      local size = math.max(vim.fn.line2byte(vim.fn.line("$") + 1) - 1, 0)
      if size < 1024 then
        return string.format("%dB", size)
      elseif size < 1048576 then
        return string.format("%.2fKiB", size / 1024)
      else
        return string.format("%.2fMiB", size / 1048576)
      end
    end

    local function get_gitsigns_strings(args)
      if MiniStatusline.is_truncated(args.trunc_width) then
        return {}
      end

      if vim.b.gitsigns_status_dict == nil then
        return {}
      end

      local out = {}
      if vim.b.gitsigns_status_dict.added ~= nil and vim.b.gitsigns_status_dict.added > 0 then
        table.insert(out, "%#diffAdded#" .. string.format("+%d", vim.b.gitsigns_status_dict.added))
      end
      if vim.b.gitsigns_status_dict.removed ~= nil and vim.b.gitsigns_status_dict.removed > 0 then
        table.insert(out, "%#diffRemoved#" .. string.format("-%d", vim.b.gitsigns_status_dict.removed))
      end
      if vim.b.gitsigns_status_dict.changed ~= nil and vim.b.gitsigns_status_dict.changed > 0 then
        table.insert(out, "%#diffChanged#" .. string.format("~%d", vim.b.gitsigns_status_dict.changed))
      end
      if #out > 0 then
        table.insert(out, 1, "%#MiniStatuslineFilename# ")
      end
      return out
    end

    local function get_diagnostic_strings(args)
      if MiniStatusline.is_truncated(args.trunc_width) then
        return {}
      end

      if vim.b.diagnostic_count == nil then
        return {}
      end

      local keys = {
        [vim.diagnostic.severity.ERROR] = { "DiagnosticError", "E" },
        [vim.diagnostic.severity.WARN] = { "DiagnosticWarn", "W" },
        [vim.diagnostic.severity.INFO] = { "DiagnosticInfo", "I" },
        [vim.diagnostic.severity.HINT] = { "DiagnosticHint", "H" },
      }

      local out = {}
      for key, val in pairs(keys) do
        local hl, symbol = unpack(val)
        local count = vim.b.diagnostic_count[key] or 0
        if count > 0 then
          table.insert(out, "%#" .. hl .. "#" .. string.format("%s%d", symbol, count))
        end
      end

      if #out > 0 then
        table.insert(out, 1, "%#MiniStatuslineFilename# ")
      end
      return out
    end

    local function get_byte_location(args)
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end
      return "%{'byte:'}%5l:%-3c"
    end

    local function get_screen_location(args)
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end

      local getpos_result = vim.fn.getpos(".")
      local cursor_row_1indexing = getpos_result[2]
      local cursor_col_1indexing = getpos_result[3]

      local winid = vim.api.nvim_get_current_win()
      local getwininfo_result = vim.fn.getwininfo(winid)[1]

      local screenpost_result = vim.fn.screenpos(0, cursor_row_1indexing, cursor_col_1indexing)

      local screen_row = screenpost_result.row
      local screen_col = screenpost_result.col - getwininfo_result.textoff

      return string.format("screen:%5d:%-3d", screen_row, screen_col)
    end

    local function get_cell_location(args)
      if MiniStatusline.is_truncated(args.trunc_width) then
        return "%5l:%-3v"
      end

      return "%{'cell:'}%5l:%-3v"
    end

    local function get_percentage(args)
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end

      return "%3p%%"
    end

    local function active()
      local groups = {}

      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local gitsigns_strings = get_gitsigns_strings({ trunc_width = 80 })
      local diagnostic_strings = get_diagnostic_strings({ trunc_width = 80 })

      local bufnr = get_bufnr({ trunc_width = 80 })
      local winnr = get_winnr({ trunc_width = 80 })
      local filename = get_filename({ trunc_width = 180 })
      local filetype = get_filetype({ trunc_width = 120 })
      local fileencoding = get_fileencoding({ trunc_width = 120 })
      local fileformat = get_fileformat({ trunc_width = 120 })
      local endofline = get_endofline({ trunc_width = 120 })
      local filesize = get_filesize({ trunc_width = 120 })

      local byte_location = get_byte_location({ trunc_width = 120 })
      local screen_location = get_screen_location({ trunc_width = 120 })
      local cell_location = get_cell_location({ trunc_width = 120 })
      local percentage = get_percentage({ trunc_width = 40 })

      local devinfo_strings = {}
      for _, s in ipairs(gitsigns_strings) do
        table.insert(devinfo_strings, s)
      end
      for _, s in ipairs(diagnostic_strings) do
        table.insert(devinfo_strings, s)
      end

      table.insert(groups, { hl = mode_hl, strings = { mode } })
      table.insert(groups, { hl = "MiniStatuslineDevinfo", strings = { bufnr, winnr } })
      table.insert(groups, { hl = "MiniStatuslineFilename", strings = { filename } })
      table.insert(groups, { strings = devinfo_strings })
      table.insert(groups, "%=")
      table.insert(groups, { hl = "MiniStatuslineFileinfo", strings = { filetype } })
      table.insert(groups, { hl = "MiniStatuslineFileinfo", strings = { fileencoding } })
      table.insert(groups, { hl = "MiniStatuslineFileinfo", strings = { fileformat } })
      table.insert(groups, { hl = "MiniStatuslineFileinfo", strings = { endofline } })
      table.insert(groups, { hl = "MiniStatuslineFileinfo", strings = { filesize } })
      table.insert(groups, {
        hl = mode_hl,
        strings = {
          byte_location,
          screen_location,
          cell_location,
          percentage,
        },
      })

      return MiniStatusline.combine_groups(groups)
    end

    MiniStatusline.setup({
      content = {
        active = active,
      },
    })
  end,
})
