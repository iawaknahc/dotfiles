local prettier = { "prettierd", "prettier", stop_after_first = true }
require("conform").setup({
  format_on_save = {},
  formatters_by_ft = {
    -- Organize imports appears as a code action,
    -- which cannot be applied synchronously in BufPreWrite.
    -- So we stick with using conform.nvim
    python = { "ruff_organize_imports", "ruff_format" },
    fennel = { "fnlfmt" },
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    css = prettier,
    -- One caveat of using cljfmt to format Hy is that f-string `f""` will be formatted to `f ""`, thus broken.
    hy = { "cljfmt" },
    swift = { "swiftformat" },
  },
})
