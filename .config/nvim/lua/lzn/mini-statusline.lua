require("lz.n").load({
  "mini.statusline",
  enabled = vim.g.pager_enabled ~= 1,
  lazy = false,
  after = function()
    local MiniStatusline = require("mini.statusline")

    local modes = {
      ["n"] = { long = "NORMAL", short = "N", hl = "MiniStatuslineModeNormal" },

      ["v"] = { long = "VISUAL", short = "V", hl = "MiniStatuslineModeVisual" },
      ["V"] = { long = "V-LINE", short = "V-L", hl = "MiniStatuslineModeVisual" },
      ["\x16"] = { long = "V-BLOCK", short = "V-B", hl = "MiniStatuslineModeVisual" },

      ["s"] = { long = "SELECT", short = "S", hl = "MiniStatuslineModeVisual" },
      ["S"] = { long = "S-LINE", short = "S-L", hl = "MiniStatuslineModeVisual" },
      ["\x13"] = { long = "S-BLOCK", short = "S-B", hl = "MiniStatuslineModeVisual" },

      ["i"] = { long = "INSERT", short = "I", hl = "MiniStatuslineModeInsert" },
      ["R"] = { long = "REPLACE", short = "R", hl = "MiniStatuslineModeReplace" },

      ["c"] = { long = "COMMAND", short = "C", hl = "MiniStatuslineModeCommand" },
      ["t"] = { long = "TERMINAL", short = "T", hl = "MiniStatuslineModeOther" },

      ["r"] = { long = "PROMPT", short = "P", hl = "MiniStatuslineModeOther" },
      ["!"] = { long = "SHELL", short = "!", hl = "MiniStatuslineModeOther" },
    }

    local function get_mode(args)
      local mode_info = modes[vim.fn.mode()]
      local mode = MiniStatusline.is_truncated(args.trunc_width) and mode_info.short or mode_info.long
      return mode, mode_info.hl
    end

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

    local function get_terminal_job_pid()
      local channel = vim.bo.channel
      local pid = vim.fn.jobpid(channel)
      return string.format("%d", pid)
    end

    ---@param win integer
    ---@return integer
    local function get_loclist_stack_size(win)
      return vim.fn.getloclist(win, { nr = "$" }).nr
    end

    ---@param win integer
    ---@return integer
    local function get_loclist_stack_index1(win)
      return vim.fn.getloclist(win, { nr = 0 }).nr
    end

    ---@param win integer
    ---@return integer
    local function get_loclist_list_size(win)
      return vim.fn.getloclist(win, { size = 0 }).size
    end

    ---@param win integer
    ---@return integer
    local function get_loclist_list_index1(win)
      return vim.fn.getloclist(win, { idx = 0 }).idx
    end

    ---@param win integer
    ---@return string
    local function get_loclist_title(win)
      return vim.fn.getloclist(win, { title = 0 }).title
    end

    ---@param win integer
    ---@return string
    local function get_loclist_filename(win)
      return "[loclist "
        .. tostring(get_loclist_stack_index1(win))
        .. "/"
        .. tostring(get_loclist_stack_size(win))
        .. "] "
        .. tostring(get_loclist_list_index1(win))
        .. "/"
        .. tostring(get_loclist_list_size(win))
        .. "  "
        .. get_loclist_title(win)
    end

    ---@return integer
    local function get_qflist_stack_size()
      return vim.fn.getqflist({ nr = "$" }).nr
    end

    ---@return integer
    local function get_qflist_stack_index1()
      return vim.fn.getqflist({ nr = 0 }).nr
    end

    ---@return integer
    local function get_qflist_list_size()
      return vim.fn.getqflist({ size = 0 }).size
    end

    ---@return integer
    local function get_qflist_list_index1()
      return vim.fn.getqflist({ idx = 0 }).idx
    end

    ---@return string
    local function get_qflist_title()
      return vim.fn.getqflist({ title = 0 }).title
    end

    ---@return string
    local function get_qflist_filename()
      return "[quickfix "
        .. tostring(get_qflist_stack_index1())
        .. "/"
        .. tostring(get_qflist_stack_size())
        .. "] "
        .. tostring(get_qflist_list_index1())
        .. "/"
        .. tostring(get_qflist_list_size())
        .. "  "
        .. get_qflist_title()
    end

    local function get_filename(args)
      local win = vim.api.nvim_get_current_win()
      local wininfo = vim.fn.getwininfo(win)[1]

      if wininfo.terminal == 1 then
        return get_terminal_job_pid() .. " %{b:term_title}"
      elseif wininfo.loclist == 1 then
        return get_loclist_filename(win)
      elseif wininfo.quickfix == 1 then
        return get_qflist_filename()
      elseif MiniStatusline.is_truncated(args.trunc_width) then
        return "%t%m%r"
      end

      return "%f%m%r"
    end

    local function get_filetype(args)
      local filetype = vim.bo.filetype
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end

      local has_devicons, devicons = pcall(require, "nvim-web-devicons")
      if not has_devicons then
        return filetype
      end

      if filetype == "" then
        return filetype
      end

      local icon = devicons.get_icon(vim.fn.expand("%:t"), nil, { default = true })
      return string.format("%s  %s", icon, filetype)
    end

    local function get_fileencoding(args)
      local fileencoding = vim.bo.fileencoding
      if MiniStatusline.is_truncated(args.trunc_width) then
        return nil
      end
      if fileencoding ~= "utf-8" then
        return { hl = "ErrorMsg", strings = { fileencoding } }
      end
      return nil
    end

    local function get_fileformat(args)
      local fileformat = vim.bo.fileformat
      if MiniStatusline.is_truncated(args.trunc_width) then
        return nil
      end
      if fileformat ~= "unix" then
        return { hl = "ErrorMsg", strings = { fileformat } }
      end
      return nil
    end

    local function get_endofline(args)
      local endofline = vim.bo.endofline
      if MiniStatusline.is_truncated(args.trunc_width) then
        return nil
      end
      if not endofline then
        return { hl = "ErrorMsg", strings = { "NOEOL" } }
      end
      return nil
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

    -- This is called utf8 location because the location reports
    -- the location in 'encoding', which is utf-8 most of the time.
    --
    -- Note that even 'filecoding' is something else, 'encoding' is still utf-8.
    local function get_utf8_location(args)
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end
      return "utf8:%5l:%-3c"
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

      return "cell:%5l:%-3v"
    end

    local function get_percentage(args)
      if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
      end

      return "%3p%%"
    end

    local function active()
      local groups = {}

      local mode, mode_hl = get_mode({ trunc_width = 120 })
      local gitsigns_strings = get_gitsigns_strings({ trunc_width = 80 })
      local diagnostic_strings = get_diagnostic_strings({ trunc_width = 80 })

      local bufnr = get_bufnr({ trunc_width = 80 })
      local winnr = get_winnr({ trunc_width = 80 })
      local filename = get_filename({ trunc_width = 180 })
      local filetype = get_filetype({ trunc_width = 120 })
      local fileencoding = get_fileencoding({ trunc_width = 80 })
      local fileformat = get_fileformat({ trunc_width = 80 })
      local endofline = get_endofline({ trunc_width = 80 })
      local filesize = get_filesize({ trunc_width = 120 })

      local utf8_location = get_utf8_location({ trunc_width = 120 })
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
      table.insert(groups, { hl = "MiniStatuslineFileinfo", strings = { filesize } })
      if fileencoding ~= nil then
        table.insert(groups, fileencoding)
      end
      if fileformat ~= nil then
        table.insert(groups, fileformat)
      end
      if endofline ~= nil then
        table.insert(groups, endofline)
      end
      table.insert(groups, {
        hl = mode_hl,
        strings = {
          utf8_location,
          screen_location,
          cell_location,
          percentage,
        },
      })

      return MiniStatusline.combine_groups(groups)
    end

    local function inactive()
      local groups = {}

      local function get_title()
        local win = vim.api.nvim_get_current_win()
        local wininfo = vim.fn.getwininfo(win)[1]

        if wininfo.terminal == 1 then
          return get_terminal_job_pid() .. " %{b:term_title}"
        elseif wininfo.loclist == 1 then
          return get_loclist_filename(win)
        elseif wininfo.quickfix == 1 then
          return get_qflist_filename()
        end

        return "%F"
      end

      local title = get_title()

      table.insert(groups, "%#MiniStatuslineInactive#")
      table.insert(groups, title)
      table.insert(groups, "%=")

      return MiniStatusline.combine_groups(groups)
    end

    MiniStatusline.setup({
      content = {
        active = active,
        inactive = inactive,
      },
    })
  end,
})
