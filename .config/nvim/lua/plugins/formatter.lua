function config()
  local formatter = require("formatter")
  local util = require("formatter.util")
  local prettierd = require("formatter.defaults.prettierd")

  local formatterGroup = vim.api.nvim_create_augroup("MyFormatterAutoCommands", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = formatterGroup,
    command = 'FormatWriteLock',
  })

  formatter.setup {
    filetype = {
      javascript = { prettierd },
      javascriptreact = { prettierd },
      typescript = { prettierd },
      typescriptreact = { prettierd },
    },
  }
end

return {
  {
    'mhartington/formatter.nvim',
    config = config,
  }
}
