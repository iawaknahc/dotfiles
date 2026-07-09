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
    lisp = { "cljfmt" },
    swift = { "swiftformat" },
    nu = { "nufmt" },
    ledger = { "hledger-fmt" },
    -- FIXME: Ideally we should use beancount-language-server to do the formatting. But there is a bug https://github.com/polarmutex/beancount-language-server/issues/874
    beancount = { "bean-format" },
    -- FIXME: Stylua, when running as an LSP server, behaves differently from running as a CLI command.
    -- Since our Git hooks run the CLI version of Stylua, we use Stylua via CLI.
    -- See https://github.com/JohnnyMorganz/StyLua/issues/1122
    lua = { "stylua" },
  },
})
