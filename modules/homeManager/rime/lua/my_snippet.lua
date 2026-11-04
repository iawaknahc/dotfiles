local M = {}

function M.today()
  local time_struct = os.date("*t")
  local time = os.time(time_struct)
  return os.date("%Y-%m-%d", time)
end

function M.tomorrow()
  local time_struct = os.date("*t")
  local day = time_struct.day + 1
  ---@cast day integer
  time_struct.day = day
  local time = os.time(time_struct)
  return os.date("%Y-%m-%d", time)
end

function M.yesterday()
  local time_struct = os.date("*t")
  local day = time_struct.day - 1
  ---@cast day integer
  time_struct.day = day
  local time = os.time(time_struct)
  return os.date("%Y-%m-%d", time)
end

function M.this_week()
  local time_struct = os.date("*t")
  local time = os.time(time_struct)
  return os.date("%G-W%V", time)
end

function M.next_week()
  local time_struct = os.date("*t")
  local day = time_struct.day + 7
  ---@cast day integer
  time_struct.day = day
  local time = os.time(time_struct)
  return os.date("%G-W%V", time)
end

function M.last_week()
  local time_struct = os.date("*t")
  local day = time_struct.day - 7
  ---@cast day integer
  time_struct.day = day
  local time = os.time(time_struct)
  return os.date("%G-W%V", time)
end

return M
