local M = {}

---@return string
function M.get_terminal_job_pid()
  local channel = vim.bo.channel
  local pid = vim.fn.jobpid(channel)
  return string.format("%d", pid)
end

---@param win integer
---@return integer
function M.get_loclist_stack_size(win)
  return vim.fn.getloclist(win, { nr = "$" }).nr
end

---@param win integer
---@return integer
function M.get_loclist_stack_index1(win)
  return vim.fn.getloclist(win, { nr = 0 }).nr
end

---@param win integer
---@return integer
function M.get_loclist_list_size(win)
  return vim.fn.getloclist(win, { size = 0 }).size
end

---@param win integer
---@return integer
function M.get_loclist_list_index1(win)
  return vim.fn.getloclist(win, { idx = 0 }).idx
end

---@param win integer
---@return string
function M.get_loclist_title(win)
  return vim.fn.getloclist(win, { title = 0 }).title
end

---@param win integer
---@return string
function M.get_loclist_filename(win)
  return "[loclist "
    .. tostring(M.get_loclist_stack_index1(win))
    .. "/"
    .. tostring(M.get_loclist_stack_size(win))
    .. "] "
    .. tostring(M.get_loclist_list_index1(win))
    .. "/"
    .. tostring(M.get_loclist_list_size(win))
    .. "  "
    .. M.get_loclist_title(win)
end

---@return integer
function M.get_qflist_stack_size()
  return vim.fn.getqflist({ nr = "$" }).nr
end

---@return integer
function M.get_qflist_stack_index1()
  return vim.fn.getqflist({ nr = 0 }).nr
end

---@return integer
function M.get_qflist_list_size()
  return vim.fn.getqflist({ size = 0 }).size
end

---@return integer
function M.get_qflist_list_index1()
  return vim.fn.getqflist({ idx = 0 }).idx
end

---@return string
function M.get_qflist_title()
  return vim.fn.getqflist({ title = 0 }).title
end

---@return string
function M.get_qflist_filename()
  return "[quickfix "
    .. tostring(M.get_qflist_stack_index1())
    .. "/"
    .. tostring(M.get_qflist_stack_size())
    .. "] "
    .. tostring(M.get_qflist_list_index1())
    .. "/"
    .. tostring(M.get_qflist_list_size())
    .. "  "
    .. M.get_qflist_title()
end

---@param winid integer
---@return string
function M.filename(winid)
  local wininfo = vim.fn.getwininfo(winid)[1]

  if wininfo ~= nil then
    if wininfo.terminal == 1 then
      return M.get_terminal_job_pid() .. " %{b:term_title}"
    elseif wininfo.loclist == 1 then
      return M.get_loclist_filename(winid)
    elseif wininfo.quickfix == 1 then
      return M.get_qflist_filename()
    end
  end

  return "%f%m%r"
end

return M
