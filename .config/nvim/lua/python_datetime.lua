local M = {}

---@param rfc3339 string
---@return integer?
function M.rfc3339_to_unix(rfc3339)
  vim.g.python_string = rfc3339

  vim.cmd([[python << EOF
import math
from datetime import datetime

import vim

rfc3339 = vim.vars["python_string"]
dt = datetime.fromisoformat(rfc3339)
unix = str(math.floor(dt.timestamp()))
vim.vars["python_string"] = unix
EOF
]])

  local ret = tonumber(vim.g.python_string)
  vim.g.python_string = nil

  return ret
end

---@param unix integer
---@return string
function M.unix_to_rfc3339(unix)
  vim.g.python_string = tostring(unix)

  vim.cmd([[python << EOF
from datetime import datetime, timezone

import vim

unix = int(vim.vars["python_string"])
dt = datetime.fromtimestamp(unix, timezone.utc)
formatted = dt.isoformat().replace("+00:00", "Z")
vim.vars["python_string"] = formatted
EOF
]])

  local ret = vim.g.python_string
  vim.g.python_string = nil
  return ret
end

return M
