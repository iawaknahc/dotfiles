local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local c = ls.choice_node
local d = ls.dynamic_node

return {
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
