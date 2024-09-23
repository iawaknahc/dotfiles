return {
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    -- rg "lazy = false" shows eagerly loaded plugins.
    lazy = false,
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "awk",
        "bash",
        "c",
        "c_sharp",
        "clojure",
        "comment",
        "cpp",
        "css",
        "csv",
        "dart",
        "diff",
        "dockerfile",
        "ebnf",
        "elixir",
        "erlang",
        "fennel",
        "fish",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "gpg",
        "graphql",
        "html",
        "http",
        "ini",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "json5",
        "kotlin",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "menhir",
        "objc",
        "ocaml",
        "ocaml_interface",
        "ocamllex",
        "passwd",
        "perl",
        "php",
        "psv",
        "python",
        "regex",
        "requirements",
        "ruby",
        "rust",
        "scss",
        "sql",
        "starlark",
        "svelte",
        "swift",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
        "xml",
        "yaml",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = true,
  },
}
