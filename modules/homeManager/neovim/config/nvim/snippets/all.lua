local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

---@return string
local function today()
  vim.cmd([[python <<EOF
import datetime
import vim

d = datetime.date.today()
vim.vars["python_string"] = d.isoformat()
EOF
]])
  return tostring(vim.g.python_string)
end

---@return string
local function yesterday()
  vim.cmd([[python <<EOF
import datetime
import vim

d = datetime.date.today() + datetime.timedelta(days=-1)
vim.vars["python_string"] = d.isoformat()
EOF
]])
  return tostring(vim.g.python_string)
end

---@return string
local function tomorrow()
  vim.cmd([[python <<EOF
import datetime
import vim

d = datetime.date.today() + datetime.timedelta(days=1)
vim.vars["python_string"] = d.isoformat()
EOF
]])
  return tostring(vim.g.python_string)
end

---@return string
local function thisweek()
  vim.cmd([[python <<EOF
import datetime
import vim

d = datetime.date.today()
vim.vars["python_string"] = d.strftime("%G-W%V")
EOF
]])
  return tostring(vim.g.python_string)
end

---@return string
local function lastweek()
  vim.cmd([[python <<EOF
import datetime
import vim

d = datetime.date.today() + datetime.timedelta(weeks=-1)
vim.vars["python_string"] = d.strftime("%G-W%V")
EOF
]])
  return tostring(vim.g.python_string)
end

---@return string
local function nextweek()
  vim.cmd([[python <<EOF
import datetime
import vim

d = datetime.date.today() + datetime.timedelta(weeks=1)
vim.vars["python_string"] = d.strftime("%G-W%V")
EOF
]])
  return tostring(vim.g.python_string)
end

return {
  s("#!py", t("#!/usr/bin/env python3")),
  s("#!nu", t("#!/usr/bin/env nu")),
  s("#!nvim", t("#!/usr/bin/env -S nvim -l")),
  s("#!sh", t("#!/bin/sh")),
  s("today", f(today, {})),
  s("yesterday", f(yesterday, {})),
  s("tomorrow", f(tomorrow, {})),
  s("thisweek", f(thisweek, {})),
  s("lastweek", f(lastweek, {})),
  s("nextweek", f(nextweek, {})),
}
