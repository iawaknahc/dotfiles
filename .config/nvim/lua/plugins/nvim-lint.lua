function config()
  local lint = require('lint')
  lint.linters_by_ft = {
    javascript = { 'eslint' },
    javascriptreact = { 'eslint' },
    typescript = { 'eslint' },
    typescriptreact = { 'eslint' },
    sh = { 'shellcheck' },
    dockerfile = { 'hadolint' },
  }

  local lintGroup = vim.api.nvim_create_augroup("MyLintAutoCommands", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = lintGroup,
    callback = function()
      lint.try_lint(nil, { ignore_errors = true })
    end,
  })
end

return {
  {
    'mfussenegger/nvim-lint',
    config = config,
  }
}
