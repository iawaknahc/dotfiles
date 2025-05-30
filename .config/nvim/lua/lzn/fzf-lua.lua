require("lz.n").load({
  "fzf-lua",
  event = { "DeferredUIEnter" },
  after = function()
    require("fzf-lua").setup({
      fzf_opts = {
        ["--layout"] = "default",
      },
      winopts = {
        preview = {
          vertical = "up:50%",
          horizontal = "right:50%",
          delay = 10,
        },
      },
    })
    -- Use fzf-lua for vim.ui.select
    require("fzf-lua").register_ui_select()
  end,
  -- Keep only the keymaps that I actually use.
  -- For others, Use <Space><Space> to run :FzfLua, and then type the name to invoke the picker fuzzily.
  keys = {
    {
      "<Space><Space>",
      "<CMD>FzfLua<CR>",
      desc = "Open FzfLua",
    },

    -- Inspired by Helix space mode f
    {
      "<Space>f",
      "<CMD>FzfLua git_files<CR>",
      desc = "Open files in workspace",
    },
    {
      "<Space>F",
      "<CMD>FzfLua files<CR>",
      desc = "Open files in working directory",
    },
    -- Inspired by Helix space mode b
    {
      "<Space>b",
      "<CMD>FzfLua buffers<CR>",
      desc = "Open buffers",
    },

    {
      "<Space>l",
      "<CMD>FzfLua loclist<CR>",
      desc = "Open location list",
    },
    {
      "<Space>q",
      "<CMD>FzfLua quickfix<CR>",
      desc = "Open quickfix list",
    },

    -- Diagnostics is preferred over loclist because it supports severity.
    --vim.keymap.set('n', '<Space>l', function() require('telescope.builtin').loclist({ show_line = false }) end)
    -- Inspired by Helix space mode d
    {
      "<Space>d",
      "<CMD>FzfLua diagnostics_document<CR>",
      desc = "Open diagnostics",
    },
    -- Inspired by Helix space mode D
    {
      "<Space>D",
      "<CMD>FzfLua diagnostics_workspace<CR>",
      desc = "Open diagnostics in workspace",
    },

    {
      "<Space>h",
      function()
        local ok, gitsigns = pcall(require, "gitsigns")
        if ok then
          local buf = 0
          gitsigns.setqflist(buf, {
            use_location_list = true,
            open = true,
          })
        end
      end,
      desc = "Open unstaged hunks in buffer",
    },
    {
      "<Space>H",
      function()
        local ok, gitsigns = pcall(require, "gitsigns")
        if ok then
          gitsigns.setqflist("all", {
            use_location_list = false,
            open = true,
          })
        end
      end,
      desc = "Open unstaged hunks in workspace",
    },
  },
})
