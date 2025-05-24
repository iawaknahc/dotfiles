require("lz.n").load({
  "nvim-lint",
  event = { "DeferredUIEnter" },
  after = function()
    require("lint").linters_by_ft = {
      javascript = { "eslint" },
      javascriptreact = { "eslint" },
      typescript = { "eslint" },
      typescriptreact = { "eslint" },
      sh = { "shellcheck" },
      dockerfile = { "hadolint" },
    }

    local lintGroup = vim.api.nvim_create_augroup("MyLintAutoCommands", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = lintGroup,
      callback = function()
        require("lint").try_lint(nil, { ignore_errors = true })
      end,
    })
  end,
})
