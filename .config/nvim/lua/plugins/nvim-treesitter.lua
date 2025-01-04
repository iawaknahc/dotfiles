local ensure_installed = {
  "awk",
  "bash",
  "c",
  "c_sharp",
  "clojure",
  "cmake",
  "comment",
  "cpp",
  "css",
  "csv",
  "dart",
  "diff",
  "dockerfile",
  "dtd",
  "ebnf",
  "editorconfig",
  "eds",
  "eex",
  "embedded_template",
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
  "gotmpl",
  "gowork",
  "gpg",
  "graphql",
  "haskell",
  "heex",
  "helm",
  "html",
  "http",
  "ini",
  "java",
  "javascript",
  "jq",
  "jsdoc",
  "json",
  "json5",
  "jsonc",
  "kotlin",
  "lua",
  "luadoc",
  "luap",
  "make",
  "markdown",
  "markdown_inline",
  "menhir",
  "mermaid",
  "ninja",
  "nginx",
  "nix",
  "nu",
  "objc",
  "objdump",
  "ocaml",
  "ocaml_interface",

  -- nvim-treesitter thinks this parser require generate from grammar.
  -- Generate from grammar requires node.
  -- See https://github.com/nvim-treesitter/nvim-treesitter/blob/master/lua/nvim-treesitter/install.lua#L371
  -- To make node available to neovim, we need to set programs.neovim.withNodeJs = true in home-manager.
  "ocamllex",

  "pem",
  "passwd",
  "perl",
  "php",
  "php_only",
  "po",
  "powershell",
  "printf",
  "promql",
  "properties",
  "psv",
  "pymanifest",
  "python",
  "query",
  "readline",
  "regex",
  "requirements",
  "rescript",
  "robots",
  "rst",
  "ruby",
  "rust",
  "scss",
  "sql",
  "ssh_config",

  -- nvim-treesitter thinks this parser require generate from grammar.
  -- Generate from grammar requires node.
  -- See https://github.com/nvim-treesitter/nvim-treesitter/blob/master/lua/nvim-treesitter/install.lua#L371
  -- To make node available to neovim, we need to set programs.neovim.withNodeJs = true in home-manager.
  "swift",

  "tmux",
  "toml",
  "tsv",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "vue",
  "xml",
  "yaml",
}

local highlight = {
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
}

local incremental_selection = {
  enable = true,
  keymaps = {
    -- This overrides :h gv
    init_selection = "gv",
    -- There is no v_CTRL-K nor v_CTRL-J.
    node_incremental = "<C-k>",
    node_decremental = "<C-j>",
    scope_incremental = false,
  },
}

local textobjects = {
  select = {
    enable = true,
    keymaps = {
      -- a stands for argument.
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
      -- m stands for method, resembles the builtin [m
      ["am"] = "@function.outer",
      ["im"] = "@function.inner",
    },
  },
  move = {
    enable = true,
    goto_next_start = {
      ["]a"] = "@parameter.outer",
      ["]m"] = "@function.outer",
    },
    goto_next_end = {
      ["]A"] = "@parameter.outer",
      ["]M"] = "@function.outer",
    },
    goto_previous_start = {
      ["[a"] = "@parameter.outer",
      ["[m"] = "@function.outer",
    },
    goto_previous_end = {
      ["[A"] = "@parameter.outer",
      ["[M"] = "@function.outer",
    },
  },
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    event = {
      "VeryLazy",
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    -- Make ; and , work with the new movements.
    -- In particular, ; and , are overridden, so f,F,t,T has to be remapped to restore the original behavior.
    -- See https://github.com/nvim-treesitter/nvim-treesitter-textobjects#:~:text=you%20can%20make%20the%20movements%20repeatable%20like
    keys = {
      {
        ";",
        function()
          require("nvim-treesitter.textobjects.repeatable_move").repeat_last_move()
        end,
        mode = { "n", "x", "o" },
        desc = ":help ;",
      },
      {
        ",",
        function()
          require("nvim-treesitter.textobjects.repeatable_move").repeat_last_move_opposite()
        end,
        mode = { "n", "x", "o" },
        desc = ":help ,",
      },
      {
        "f",
        function()
          return require("nvim-treesitter.textobjects.repeatable_move").builtin_f_expr()
        end,
        mode = { "n", "x", "o" },
        expr = true,
        desc = ":help f",
      },
      {
        "F",
        function()
          return require("nvim-treesitter.textobjects.repeatable_move").builtin_F_expr()
        end,
        mode = { "n", "x", "o" },
        expr = true,
        desc = ":help F",
      },
      {
        "t",
        function()
          return require("nvim-treesitter.textobjects.repeatable_move").builtin_t_expr()
        end,
        mode = { "n", "x", "o" },
        expr = true,
        desc = ":help t",
      },
      {
        "T",
        function()
          return require("nvim-treesitter.textobjects.repeatable_move").builtin_T_expr()
        end,
        mode = { "n", "x", "o" },
        expr = true,
        desc = ":help T",
      },
    },
    config = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup {
        ensure_installed = ensure_installed,
        highlight = highlight,
        incremental_selection = incremental_selection,
        textobjects = textobjects,
      }
    end,
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
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    enabled = true,
    lazy = true,
    config = false,
  },
}
