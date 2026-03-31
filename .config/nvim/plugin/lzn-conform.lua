local prettier = { "prettierd", "prettier", stop_after_first = true }
require("conform").setup({
  format_on_save = {},
  formatters_by_ft = {
    go = { "gofmt" },
    python = { "ruff_organize_imports", "ruff_format" },
    lua = { "stylua" },
    fennel = { "fnlfmt" },
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    clojure = { "cljfmt" },
    css = prettier,
    dart = { "dart_format" },
    fish = { "fish_indent" },
    -- One caveat of using cljfmt to format Hy is that f-string `f""` will be formatted to `f ""`, thus broken.
    hy = { "cljfmt" },
    nix = { "nixfmt" },
    swift = { "swiftformat" },
  },
})
