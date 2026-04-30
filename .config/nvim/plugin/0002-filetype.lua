-- If you run :checkhealth, we may still see a warning saying yaml.docker-compose is not a valid filetype.
-- For a filetype to be considered as valid, there have to be a `ftplugin/<filetype>.{vim,lua}`
-- But it is really a warning.
vim.filetype.add({
  extension = {
    mjml = "html",
  },
  filename = {
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["docker-compose.yml"] = "yaml.docker-compose",
  },
})

local SHEBANGS = {
  [ [[^#!/usr/bin/env deno$]] ] = "typescript",
}

vim.filetype.add({
  pattern = {
    [".*"] = {
      function(_path, bufnr)
        local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
        for pattern, filetype in pairs(SHEBANGS) do
          if vim.regex(pattern):match_str(content) ~= nil then
            return filetype
          end
        end
      end,
      { priority = -math.huge },
    },
  },
})
