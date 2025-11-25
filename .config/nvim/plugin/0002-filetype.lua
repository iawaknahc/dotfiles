local myfiletype_autocmdgroup = vim.api.nvim_create_augroup("MyFiletype", { clear = true })

local function myautocmd_set_filetype(pattern, filetype)
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = myfiletype_autocmdgroup,
    pattern = pattern,
    callback = function()
      vim.bo.filetype = filetype
    end,
  })
end

-- By default, filetype.vim treats *.env as sh
-- We do NOT want to run any before-save fix on *.env
-- For example, some envvars may have trailing whitespaces we do want to preserve.
myautocmd_set_filetype("*.env", "")
-- mjml
myautocmd_set_filetype("*.mjml", "html")
myautocmd_set_filetype("docker-compose.yaml", "yaml.docker-compose")
myautocmd_set_filetype("docker-compose.yml", "yaml.docker-compose")
