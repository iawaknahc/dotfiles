local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node

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
  s("today", f(today)),
  s("yesterday", f(yesterday)),
  s("tomorrow", f(tomorrow)),
  s("thisweek", f(thisweek)),
  s("lastweek", f(lastweek)),
  s("nextweek", f(nextweek)),
  s(
    "path",
    d(1, function()
      local absolute_path_to_global_working_directory = vim.fn.getcwd(-1, -1)
      local absolute_path_to_local_working_directory = vim.fn.getcwd(0, 0)
      local absolute_path_to_buffer = vim.fn.expand("%:p") --[[@as string]]
      local relative_path_of_buffer_to_global_working_directory =
        vim.fs.relpath(absolute_path_to_global_working_directory, absolute_path_to_buffer)
      local relative_path_of_buffer_to_local_working_directory =
        vim.fs.relpath(absolute_path_to_local_working_directory, absolute_path_to_buffer)

      local choices = {
        t(absolute_path_to_global_working_directory),
      }

      if
        absolute_path_to_local_working_directory ~= absolute_path_to_global_working_directory
        and absolute_path_to_local_working_directory ~= ""
      then
        table.insert(choices, t(absolute_path_to_local_working_directory))
      end

      if absolute_path_to_buffer ~= "" then
        table.insert(choices, t(absolute_path_to_buffer))
      end

      if
        relative_path_of_buffer_to_global_working_directory ~= nil
        and relative_path_of_buffer_to_global_working_directory ~= ""
        and relative_path_of_buffer_to_global_working_directory ~= "."
      then
        table.insert(choices, t("./" .. relative_path_of_buffer_to_global_working_directory))
        if
          relative_path_of_buffer_to_local_working_directory ~= nil
          and relative_path_of_buffer_to_local_working_directory ~= ""
          and relative_path_of_buffer_to_local_working_directory ~= "."
          and relative_path_of_buffer_to_local_working_directory
            ~= relative_path_of_buffer_to_global_working_directory
        then
          table.insert(choices, t("./" .. relative_path_of_buffer_to_local_working_directory))
        end
      end

      if #choices == 1 then
        return sn(nil, choices[1])
      end
      return sn(nil, c(1, choices))
    end)
  ),
}
