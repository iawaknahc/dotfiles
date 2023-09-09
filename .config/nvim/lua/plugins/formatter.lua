function config()
  local formatter = require("formatter")
  local util = require("formatter.util")

  local formatterGroup = vim.api.nvim_create_augroup("MyFormatterAutoCommands", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = formatterGroup,
    command = "FormatWriteLock",
  })

  local prettier = {
    exe = "./node_modules/.bin/prettier",
    args = {
      "--stdin-filepath",
      util.escape_path(util.get_current_buffer_file_path()),
    },
    stdin = true,
  }

  -- I used to use prettierd but it seems that it is not compatible with projects
  -- that have prettier plugins installed.

  formatter.setup {
    filetype = {
      javascript = { prettier },
      javascriptreact = { prettier },
      typescript = { prettier },
      typescriptreact = { prettier },
      css = { prettier },
      lua = { require("formatter.filetypes.lua").stylua },
    },
  }
end

return {
  {
    "mhartington/formatter.nvim",
    config = config,
  },
}
