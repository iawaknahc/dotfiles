local M = {}

---@param s string
---@return { scheme: string, netloc: string, path: string, query: string, fragment: string }
function M.urlsplit(s)
  vim.g.python_string = s

  vim.cmd([[python << EOF
import json
import urllib.parse

import vim

s = vim.vars["python_string"]
split_result = urllib.parse.urlsplit(s)
serialized = json.dumps({
  "scheme": split_result.scheme,
  "netloc": split_result.netloc,
  "path": split_result.path,
  "query": split_result.query,
  "fragment": split_result.fragment,
})
vim.vars["python_string"] = serialized
EOF
]])

  local ret = vim.json.decode(vim.g.python_string)
  vim.g.python_string = nil
  return ret
end

return M
