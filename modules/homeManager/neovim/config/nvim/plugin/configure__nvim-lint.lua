require("lint").linters_by_ft = {
  sh = { "shellcheck" },
  dockerfile = { "hadolint" },
}

local function codespell(ev)
  -- Run if the file is not big, and it is a normal buffer.
  if vim.bo[ev.buf].filetype ~= "bigfile" and vim.bo[ev.buf].buftype == "" then
    require("lint").try_lint({ "codespell" }, { ignore_errors = true })
  end
end

local lintGroup = vim.api.nvim_create_augroup("MyLintAutoCommands", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = lintGroup,
  callback = codespell,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = lintGroup,
  callback = codespell,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = lintGroup,
  callback = function()
    -- Run the linters_by_ft
    require("lint").try_lint(nil, { ignore_errors = true })
  end,
})
