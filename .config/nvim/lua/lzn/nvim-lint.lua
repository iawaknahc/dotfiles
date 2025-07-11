require("lz.n").load({
  "nvim-lint",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    require("lint").linters_by_ft = {
      sh = { "shellcheck" },
      dockerfile = { "hadolint" },
      python = { "ruff" },
    }

    local lintGroup = vim.api.nvim_create_augroup("MyLintAutoCommands", { clear = true })
    vim.api.nvim_create_autocmd("InsertLeave", {
      group = lintGroup,
      callback = function()
        local lint = require("lint")

        -- Run these always.
        lint.try_lint({
          "codespell",
        }, { ignore_errors = true })
      end,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
      group = lintGroup,
      callback = function()
        local lint = require("lint")

        -- Run the linters_by_ft
        lint.try_lint(nil, { ignore_errors = true })
      end,
    })
  end,
})
