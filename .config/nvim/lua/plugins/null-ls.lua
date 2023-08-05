function config()
  local null_ls = require('null-ls')

  null_ls.setup {
    sources = {
      null_ls.builtins.diagnostics.shellcheck,
      null_ls.builtins.diagnostics.hadolint,
      null_ls.builtins.diagnostics.eslint_d,
      null_ls.builtins.formatting.prettierd.with {
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          -- "css",
          -- "scss",
          -- "html",
        }
      },
    },
  }
end

return {
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = config,
  },
}
