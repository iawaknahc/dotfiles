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
        -- nvim-treesitter thinks this need to require generate from grammar.
        -- Generate from grammar requires node.
        -- I do not want to install node globally just for install a parser.
        -- See https://github.com/nvim-treesitter/nvim-treesitter/blob/master/lua/nvim-treesitter/install.lua#L371
        -- "ocamllex",
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
        "ssh_config",
        "starlark",
        "svelte",
        -- nvim-treesitter thinks this need to require generate from grammar.
        -- Generate from grammar requires node.
        -- I do not want to install node globally just for install a parser.
        -- See https://github.com/nvim-treesitter/nvim-treesitter/blob/master/lua/nvim-treesitter/install.lua#L371
        -- "swift",
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
        disable = function(_, bufnr)
          local max_filesize = 100 * 1024 -- 100KiB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          if ok and stats and stats.size > max_filesize then
            return true
          end
          return false
        end,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = true,
    event = {
      "VeryLazy",
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = true,
  },
}
