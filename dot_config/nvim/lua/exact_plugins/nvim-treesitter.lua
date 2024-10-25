return {
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    event = {
      "VeryLazy",
    },
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
        "nix",
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
        -- Disable highlight on large files.
        -- This can avoid hang.
        disable = function (_, bufnr)
          local max_filesize = 100 * 1024 -- 100KiB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          if ok and stats and stats.size > max_filesize then
            return true
          end
          return false
        end
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = {
      "VeryLazy",
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = true,
  },
}
