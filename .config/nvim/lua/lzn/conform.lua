require("lz.n").load({
  "conform.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    -- https://github.com/stevearc/conform.nvim/commit/9f111be14818c91832db8f320c4a4aa68de0e00b
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
        hy = { "cljfmt" },
        nix = { "nixfmt" },
        swift = { "swiftformat" },
      },
    })
  end,
})
