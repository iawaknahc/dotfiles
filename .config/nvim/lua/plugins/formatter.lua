function config()
  local formatter = require("formatter")
  local util = require("formatter.util")
  -- I used to use prettierd but it seems that it is not compatible with projects
  -- that have prettier plugins installed.
  local prettier = require("formatter.defaults.prettier")

  local formatterGroup = vim.api.nvim_create_augroup("MyFormatterAutoCommands", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = formatterGroup,
    command = 'FormatWriteLock',
  })

  formatter.setup {
    filetype = {
      javascript = { prettier },
      javascriptreact = { prettier },
      typescript = { prettier },
      typescriptreact = { prettier },
      css = { prettier },
    },
  }
end

return {
  {
    'mhartington/formatter.nvim',
    config = config,
  }
}
