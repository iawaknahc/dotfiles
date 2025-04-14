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
      -- a stands for assignment.
      ["aa"] = { query = "@assignment.outer", desc = "assignment" },
      ["ia"] = { query = "@assignment.inner", desc = "inner assignment" },
      -- b stands for block.
      -- Override :h ab and :h ib
      ["ab"] = { query = "@block.outer", desc = "block" },
      ["ib"] = { query = "@block.inner", desc = "inner block" },
      -- c stands for class.
      ["ac"] = { query = "@class.outer", desc = "class" },
      ["ic"] = { query = "@class.inner", desc = "inner class" },
      -- l stands for loop.
      ["al"] = { query = "@loop.outer", desc = "loop" },
      ["il"] = { query = "@loop.inner", desc = "inner loop" },
      -- m stands for method, resembles the builtin [m
      ["am"] = { query = "@function.outer", desc = "method or function" },
      ["im"] = { query = "@function.inner", desc = "inner method or function" },
      -- p stands for parameter.
      -- Override :h ap and :h ip
      ["ap"] = { query = "@parameter.outer", desc = "parameter" },
      ["ip"] = { query = "@parameter.inner", desc = "inner parameter" },
      -- s stands for statement.
      ["as"] = { query = "@statement.outer", desc = "statement" },
      ["is"] = { query = "@statement.inner", desc = "inner statement" },
    },
  },
  move = {
    enable = true,
    goto_next_start = {
      ["]a"] = { query = "@assignment.outer", desc = "Next start of assignment" },
      ["]b"] = { query = "@block.outer", desc = "Next start of block" },
      ["]c"] = { query = "@class.outer", desc = "Next start of class" },
      ["]l"] = { query = "@loop.outer", desc = "Next start of loop" },
      -- Override :h ]m
      ["]m"] = { query = "@function.outer", desc = "Next start of method or function" },
      ["]p"] = { query = "@parameter.outer", desc = "Next start of parameter" },
      -- Override :h ]s
      ["]s"] = { query = "@statement.outer", desc = "Next start of statement" },
    },
    goto_next_end = {
      ["]A"] = { query = "@assignment.outer", desc = "Next end of assignment" },
      ["]B"] = { query = "@block.outer", desc = "Next end of block" },
      ["]C"] = { query = "@class.outer", desc = "Next end of class" },
      ["]L"] = { query = "@loop.outer", desc = "Next end of loop" },
      -- Override :h ]M
      ["]M"] = { query = "@function.outer", desc = "Next end of method or function" },
      ["]P"] = { query = "@parameter.outer", desc = "Next end of parameter" },
      -- Override :h ]S
      ["]S"] = { query = "@statement.outer", desc = "Next end of statement" },
    },
    goto_previous_start = {
      ["[a"] = { query = "@assignment.outer", desc = "Previous start of assignment" },
      ["[b"] = { query = "@block.outer", desc = "Previous start of block" },
      ["[c"] = { query = "@class.outer", desc = "Previous start of class" },
      ["[l"] = { query = "@loop.outer", desc = "Previous start of loop" },
      -- Override :h [m
      ["[m"] = { query = "@function.outer", desc = "Previous start of method or function" },
      ["[p"] = { query = "@parameter.outer", desc = "Previous start of parameter" },
      -- Override :h [s
      ["[s"] = { query = "@statement.outer", desc = "Previous start of statement" },
    },
    goto_previous_end = {
      ["[A"] = { query = "@assignment.outer", desc = "Previous end of assignment" },
      ["[B"] = { query = "@block.outer", desc = "Previous end of block" },
      ["[C"] = { query = "@class.outer", desc = "Previous end of class" },
      ["[L"] = { query = "@loop.outer", desc = "Previous end of loop" },
      -- Override :h [M
      ["[M"] = { query = "@function.outer", desc = "Previous end of method or function" },
      ["[P"] = { query = "@parameter.outer", desc = "Previous end of parameter" },
      -- Override :h [S
      ["[S"] = { query = "@statement.outer", desc = "Previous end of statement" },
    },
  },
  swap = {
    enable = true,
    swap_next = {
      -- Override :h gs
      ["gsp"] = { query = "@parameter.inner", desc = "Swap with next parameter" },
      ["gss"] = { query = "@statement.outer", desc = "Swap with next statement" },
    },
    swap_previous = {
      -- Override :h gs
      ["gsP"] = { query = "@parameter.inner", desc = "Swap with previous parameter" },
      ["gsS"] = { query = "@statement.outer", desc = "Swap with previous statement" },
    },
  },
}

require("lz.n").load({
  "nvim-treesitter-textobjects",
  lazy = true,
})

require("lz.n").load({
  "nvim-treesitter-context",
  lazy = true,
})

require("lz.n").load({
  "nvim-treesitter",
  after = function()
    require("lz.n").trigger_load("nvim-treesitter-textobjects")
    require("lz.n").trigger_load("nvim-treesitter-context")

    local configs = require("nvim-treesitter.configs")
    configs.setup({
      highlight = highlight,
      incremental_selection = incremental_selection,
      textobjects = textobjects,
    })
  end,
  event = { "DeferredUIEnter" },
  keys = {
    {
      ";",
      function()
        require("nvim-treesitter.textobjects.repeatable_move").repeat_last_move()
      end,
      mode = { "n", "x", "o" },
      desc = "Repeat ftFT",
    },
    {
      ",",
      function()
        require("nvim-treesitter.textobjects.repeatable_move").repeat_last_move_opposite()
      end,
      mode = { "n", "x", "o" },
      desc = "Repeat ftFT",
    },
    {
      "f",
      function()
        return require("nvim-treesitter.textobjects.repeatable_move").builtin_f_expr()
      end,
      mode = { "n", "x", "o" },
      expr = true,
      desc = "Next char",
    },
    {
      "F",
      function()
        return require("nvim-treesitter.textobjects.repeatable_move").builtin_F_expr()
      end,
      mode = { "n", "x", "o" },
      expr = true,
      desc = "Prev char",
    },
    {
      "t",
      function()
        return require("nvim-treesitter.textobjects.repeatable_move").builtin_t_expr()
      end,
      mode = { "n", "x", "o" },
      expr = true,
      desc = "Til next char",
    },
    {
      "T",
      function()
        return require("nvim-treesitter.textobjects.repeatable_move").builtin_T_expr()
      end,
      mode = { "n", "x", "o" },
      expr = true,
      desc = "Til prev char",
    },
  },
})
