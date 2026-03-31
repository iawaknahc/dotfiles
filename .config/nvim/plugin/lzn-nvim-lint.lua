require("lint").linters_by_ft = {
  sh = { "shellcheck" },
  dockerfile = { "hadolint" },
  python = { "ruff" },
}

local lintGroup = vim.api.nvim_create_augroup("MyLintAutoCommands", { clear = true })
vim.api.nvim_create_autocmd("InsertLeave", {
  group = lintGroup,
  callback = function()
    -- Run these always.
    require("lint").try_lint({ "codespell" }, { ignore_errors = true })
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = lintGroup,
  callback = function()
    -- Run the linters_by_ft
    require("lint").try_lint(nil, { ignore_errors = true })
  end,
})
