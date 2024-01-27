local prettier = { { "prettierd", "prettier" } }

return {
  "stevearc/conform.nvim",
  opts = {
    format_on_save = {},
    formatters_by_ft = {
      go = { "gofmt" },
      lua = { "stylua" },
      javascript = prettier,
      javascriptreact = prettier,
      typescript = prettier,
      typescriptreact = prettier,
      css = prettier,
    },
  },
}