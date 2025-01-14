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

require("lz.n").load {
  "nvim-treesitter-textobjects",
  lazy = true,
}

require("lz.n").load {
  "nvim-treesitter-context",
  lazy = true,
}

require("lz.n").load {
  "nvim-treesitter",
  after = function()
    require("lz.n").trigger_load("nvim-treesitter-textobjects")
    require("lz.n").trigger_load("nvim-treesitter-context")

    local configs = require("nvim-treesitter.configs")
    configs.setup {
      highlight = highlight,
      incremental_selection = incremental_selection,
      textobjects = textobjects,
    }
  end,
  event = { "DeferredUIEnter" },
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
}
