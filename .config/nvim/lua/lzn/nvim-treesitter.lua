require("lz.n").load({
  "nvim-treesitter-textobjects",
  lazy = true,
})

require("lz.n").load({
  "nvim-treesitter",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    require("lz.n").trigger_load("nvim-treesitter-textobjects")

    local configs = require("nvim-treesitter.configs")
    configs.setup({
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
      -- incremental_selection is deprecated in a future version of nvim-treesitter
      -- See https://github.com/nvim-treesitter/nvim-treesitter/issues/4767
      -- And its functionality is superseded by require("flash").treesitter()
      incremental_selection = {
        enable = false,
      },
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            -- a stands for assignment.
            ["aa"] = { query = "@assignment.outer", desc = "assignment" },
            ["ia"] = { query = "@assignment.inner", desc = "assignment" },
            -- b stands for block.
            -- Override :h ab and :h ib
            ["ab"] = { query = "@block.outer", desc = "block" },
            ["ib"] = { query = "@block.inner", desc = "block" },
            -- c stands for class.
            ["ac"] = { query = "@class.outer", desc = "class" },
            ["ic"] = { query = "@class.inner", desc = "class" },
            -- :h ]l and :h [l are mapped by default to navigate loclist.
            -- m stands for method, resembles the builtin [m
            ["am"] = { query = "@function.outer", desc = "function" },
            ["im"] = { query = "@function.inner", desc = "function" },
            -- p stands for parameter.
            -- Override :h ap and :h ip
            ["ap"] = { query = "@parameter.outer", desc = "parameter" },
            ["ip"] = { query = "@parameter.inner", desc = "parameter" },
            -- s stands for statement.
            ["as"] = { query = "@statement.outer", desc = "statement" },
            ["is"] = { query = "@statement.inner", desc = "statement" },
          },
        },
        move = {
          enable = true,
          goto_next_start = {
            ["]a"] = { query = "@assignment.outer", desc = "assignment" },
            ["]b"] = { query = "@block.outer", desc = "block" },
            ["]c"] = { query = "@class.outer", desc = "class" },
            -- :h ]l and :h [l are mapped by default to navigate loclist.
            -- Override :h ]m
            ["]m"] = { query = "@function.outer", desc = "function" },
            ["]p"] = { query = "@parameter.outer", desc = "parameter" },
            -- Override :h ]s
            ["]s"] = { query = "@statement.outer", desc = "statement" },
          },
          goto_next_end = {
            ["]A"] = { query = "@assignment.outer", desc = "assignment" },
            ["]B"] = { query = "@block.outer", desc = "block" },
            ["]C"] = { query = "@class.outer", desc = "class" },
            -- :h ]l and :h [l are mapped by default to navigate loclist.
            -- Override :h ]M
            ["]M"] = { query = "@function.outer", desc = "function" },
            ["]P"] = { query = "@parameter.outer", desc = "parameter" },
            -- Override :h ]S
            ["]S"] = { query = "@statement.outer", desc = "statement" },
          },
          goto_previous_start = {
            ["[a"] = { query = "@assignment.outer", desc = "assignment" },
            ["[b"] = { query = "@block.outer", desc = "block" },
            ["[c"] = { query = "@class.outer", desc = "class" },
            -- :h ]l and :h [l are mapped by default to navigate loclist.
            -- Override :h [m
            ["[m"] = { query = "@function.outer", desc = "function" },
            ["[p"] = { query = "@parameter.outer", desc = "parameter" },
            -- Override :h [s
            ["[s"] = { query = "@statement.outer", desc = "statement" },
          },
          goto_previous_end = {
            ["[A"] = { query = "@assignment.outer", desc = "assignment" },
            ["[B"] = { query = "@block.outer", desc = "block" },
            ["[C"] = { query = "@class.outer", desc = "class" },
            -- :h ]l and :h [l are mapped by default to navigate loclist.
            -- Override :h [M
            ["[M"] = { query = "@function.outer", desc = "function" },
            ["[P"] = { query = "@parameter.outer", desc = "parameter" },
            -- Override :h [S
            ["[S"] = { query = "@statement.outer", desc = "statement" },
          },
        },
        swap = {
          enable = false,
        },
      },
    })
  end,
})
