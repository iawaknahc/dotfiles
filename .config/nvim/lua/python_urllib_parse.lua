local M = {}

---@param s string
---@return { scheme: string, netloc: string, path: string, query: string, fragment: string }
function M.urlsplit(s)
  local bak = vim.fn.getreginfo("a")
  vim.fn.setreg("a", s)
  vim.cmd([[python << EOF
import json
import urllib.parse
s = vim.eval("@a")
split_result = urllib.parse.urlsplit(s)
serialized = json.dumps({
  "scheme": split_result.scheme,
  "netloc": split_result.netloc,
  "path": split_result.path,
  "query": split_result.query,
  "fragment": split_result.fragment,
})
vim.command("let @a=" + repr(serialized))
EOF
]])
  -- https://github.com/neovim/neovim/pull/34215
  ---@diagnostic disable-next-line: redundant-parameter
  local result = vim.fn.getreg("a", 1, false) --[[@as string]]
  vim.fn.setreg("a", bak)
  return vim.json.decode(result)
end

return M
