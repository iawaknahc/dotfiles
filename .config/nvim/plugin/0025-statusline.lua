---@alias StatuslineItem StatuslineItemString|StatuslineItemGroup|StatuslineItemList

---@alias StatuslineItemString string

---@class StatuslineItemGroup
---@field item StatuslineItem
---@field hl? string

---@alias StatuslineItemList StatuslineItem[]

---@return boolean
local function is_active()
  local winid = vim.api.nvim_get_current_win()
  local actual_winid = vim.g.actual_curwin
  return tostring(winid) == tostring(actual_winid)
end

---@param item StatuslineItem
---@return string
local function StatuslineItem_to_statusline(item)
  if type(item) == "string" then
    return item
  end
  if type(item) == "table" then
    if item.item ~= nil then
      local item_ = item --[[@as StatuslineItemGroup]]
      local s = StatuslineItem_to_statusline(item_.item)

      local trimmed = vim.trim(s)
      if trimmed == "" then
        s = trimmed
      end

      local default_hl = "StatusLineNC"
      if is_active() then
        default_hl = "StatusLine"
      end

      local hl = item_.hl or default_hl
      return "%#" .. hl .. "#" .. "%(" .. s .. "%)" .. "%*"
    else
      local list_ = item --[[@as StatuslineItemList]]
      local parts = {}
      for _, i in ipairs(list_) do
        table.insert(parts, StatuslineItem_to_statusline(i))
      end
      return table.concat(parts, "")
    end
  end

  error("unexpected item: " .. vim.inspect(item))
end

local modes = {
  ["n"] = { label = "NORMAL", hl = "MiniStatuslineModeNormal" },

  ["v"] = { label = "VISUAL", hl = "MiniStatuslineModeVisual" },
  ["V"] = { label = "V-LINE", hl = "MiniStatuslineModeVisual" },
  ["\x16"] = { label = "V-BLOCK", hl = "MiniStatuslineModeVisual" },

  ["s"] = { label = "SELECT", hl = "MiniStatuslineModeVisual" },
  ["S"] = { label = "S-LINE", hl = "MiniStatuslineModeVisual" },
  ["\x13"] = { label = "S-BLOCK", hl = "MiniStatuslineModeVisual" },

  ["i"] = { label = "INSERT", hl = "MiniStatuslineModeInsert" },
  ["R"] = { label = "REPLACE", hl = "MiniStatuslineModeReplace" },

  ["c"] = { label = "COMMAND", hl = "MiniStatuslineModeCommand" },
  ["t"] = { label = "TERMINAL", hl = "MiniStatuslineModeOther" },

  ["r"] = { label = "PROMPT", hl = "MiniStatuslineModeOther" },
  ["!"] = { label = "SHELL", hl = "MiniStatuslineModeOther" },
}

---@return StatuslineItemGroup
local function statusline_mode()
  local mode_info = modes[vim.fn.mode()]
  local hl = mode_info.hl
  if not is_active() then
    hl = "StatusLineNC"
  end
  return { item = " " .. mode_info.label .. " ", hl = hl }
end

---@return string
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

---@return StatuslineItemString
local function statusline_filename()
  local winid = vim.api.nvim_get_current_win()
  local wininfo = vim.fn.getwininfo(winid)[1]

  if wininfo ~= nil then
    if wininfo.terminal == 1 then
      return get_terminal_job_pid() .. " %{b:term_title}"
    elseif wininfo.loclist == 1 then
      return get_loclist_filename(winid)
    elseif wininfo.quickfix == 1 then
      return get_qflist_filename()
    end
  end

  return "%f%m%r"
end

---@return StatuslineItemString
local function statusline_bufnr()
  return "b" .. tostring(vim.api.nvim_get_current_buf())
end

---@return StatuslineItemString
local function statusline_winid()
  return "w" .. tostring(vim.api.nvim_get_current_win())
end

---@param field_name string
---@param symbol string
---@param hl string
---@return StatuslineItem
local function statusline_gitsigns(field_name, symbol, hl)
  if
    vim.b.gitsigns_status_dict ~= nil
    and type(vim.b.gitsigns_status_dict[field_name]) == "number"
    and vim.b.gitsigns_status_dict[field_name] > 0
  then
    return { item = string.format("%s%d", symbol, vim.b.gitsigns_status_dict[field_name]), hl = hl }
  end
  return ""
end

---@return StatuslineItem
local function statusline_fileencoding()
  local fileencoding = vim.bo.fileencoding
  if fileencoding ~= "utf-8" then
    return fileencoding
  end
  return ""
end

---@return StatuslineItem
local function statusline_fileformat()
  local fileformat = vim.bo.fileformat
  if fileformat ~= "unix" then
    return fileformat
  end
  return ""
end

---@return StatuslineItem
local function statusline_endofline()
  local endofline = vim.bo.endofline
  if not endofline then
    return "NOEOL"
  end
  return ""
end

local function statusline_filesize()
  local size = math.max(vim.fn.line2byte(vim.fn.line("$") + 1) - 1, 0)
  if size < 1024 then
    return string.format("%dB", size)
  elseif size < 1048576 then
    return string.format("%.2fKiB", size / 1024)
  else
    return string.format("%.2fMiB", size / 1048576)
  end
end

-- This reports the cursor position relative to the buffer 'encoding'.
-- The number shown in parenthesis is the virtual column.
-- See :help virtualedit
---@return StatuslineItemString
local function statusline_utf8_location()
  -- Typical source code files has less than 100000 lines, thus 5 is enough.
  -- Typical screen has less than 1000 columns, thus 3 is enough.
  return "utf8:%5l:%-3c(%3v)"
end

-- This reports the cursor position relative to the screen.
-- The line number is within the range [1, screen height].
-- The column number is within the range [1, screen width].
---@return StatuslineItemString
local function statusline_screen_location()
  local getpos_result = vim.fn.getpos(".")
  local cursor_row_1indexing = getpos_result[2]
  local cursor_col_1indexing = getpos_result[3]

  local winid = vim.api.nvim_get_current_win()
  local getwininfo_result = vim.fn.getwininfo(winid)[1]

  local screenpos_result = vim.fn.screenpos(0, cursor_row_1indexing, cursor_col_1indexing)

  local screen_row = screenpos_result.row
  local screen_col = 0
  if getwininfo_result ~= nil then
    screen_col = screenpos_result.col - getwininfo_result.textoff
  end

  -- 3 is enough because typical screen has less than 1000 rows and 1000 columns.
  return string.format("screen:%3d:%-3d", screen_row, screen_col)
end

---@return StatuslineItemString
local function statusline_percentage()
  return "%3p%%"
end

function STATUSLINE_STATUSLINE()
  local mode = statusline_mode()
  return StatuslineItem_to_statusline({
    mode,

    { item = { " ", statusline_bufnr(), " ", statusline_winid(), " " }, hl = "MiniStatuslineDevinfo" },
    {
      " ",
      "%<",
      statusline_filename(),
    },

    {
      item = {
        " ",
        statusline_gitsigns("added", "+", "diffAdded"),
        " ",
        statusline_gitsigns("removed", "-", "diffRemoved"),
        " ",
        statusline_gitsigns("changed", "~", "diffChanged"),
      },
    }, --[[@as StatuslineItemGroup]]
    {
      item = {
        " ",
        vim.diagnostic.status(vim.api.nvim_get_current_buf()),
      },
    },
    {
      item = {
        " ",
        statusline_fileencoding(),
        " ",
        statusline_fileformat(),
        " ",
        statusline_endofline(),
        " ",
      },
      hl = "ErrorMsg",
    },

    "%=",
    {
      item = {
        " ",
        { item = { " ", "%{&filetype}", " ", statusline_filesize(), " " }, hl = "MiniStatuslineFileinfo" },
      },
    },
    {
      item = {
        " ",
        statusline_utf8_location(),
        " ",
        statusline_screen_location(),
        " ",
        statusline_percentage(),
      },
      hl = mode.hl,
    },
  })
end

vim.o.statusline = "%{%v:lua.STATUSLINE_STATUSLINE()%}"
