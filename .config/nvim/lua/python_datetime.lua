local M = {}

---@param rfc3339 string
---@return integer?
function M.rfc3339_to_unix(rfc3339)
  local bak = vim.fn.getreginfo("a")
  vim.fn.setreg("a", rfc3339)
  vim.cmd([[python << EOF
import math
import vim
from datetime import datetime
rfc3339 = vim.eval("@a")
dt = datetime.fromisoformat(rfc3339)
unix = str(math.floor(dt.timestamp()))
vim.command("let @a=" + unix)
EOF
]])

  -- https://github.com/neovim/neovim/pull/34215
  ---@diagnostic disable-next-line: redundant-parameter
  local result = vim.fn.getreg("a", 1, false)
  vim.fn.setreg("a", bak)
  return tonumber(result)
end

---@param unix integer
---@return string
function M.unix_to_rfc3339(unix)
  local bak = vim.fn.getreginfo("a")
  vim.fn.setreg("a", tostring(unix))
  vim.cmd([[python << EOF
from datetime import datetime, timezone
unix = int(vim.eval("@a"))
dt = datetime.fromtimestamp(unix, timezone.utc)
formatted = dt.isoformat().replace("+00:00", "Z")
vim.command("let @a=" + repr(formatted))
EOF
]])

  -- https://github.com/neovim/neovim/pull/34215
  ---@diagnostic disable-next-line: redundant-parameter
  local result = vim.fn.getreg("a", 1, false) --[[@as string]]
  vim.fn.setreg("a", bak)
  return result
end

return M
