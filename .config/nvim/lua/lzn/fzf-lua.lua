require("lz.n").load({
  "fzf-lua",
  after = function()
    local actions = require("fzf-lua").actions

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
      git = {
        status = {
          actions = {
            -- By default left to stage, right to unstage.
            ["left"] = false,
            ["right"] = false,
            -- Remove the keymap to discard changes in a file.
            ["ctrl-x"] = false,
            ["ctrl-s"] = {
              fn = actions.git_stage_unstage,
              reload = true,
            },
          },
        },
      },
    })
    -- Use fzf-lua for vim.ui.select
    require("fzf-lua").register_ui_select()
  end,
  cmd = "FzfLua",
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

    -- https://gpanders.com/blog/whats-new-in-neovim-0-11/#more-default-mappings
    {
      "gri",
      "<CMD>FzfLua lsp_implementations<CR>",
      desc = "Open implementations",
    },
    -- https://gpanders.com/blog/whats-new-in-neovim-0-11/#more-default-mappings
    {
      "grr",
      "<CMD>FzfLua lsp_references<CR>",
      desc = "Open references",
    },
    -- https://gpanders.com/blog/whats-new-in-neovim-0-11/#more-default-mappings
    {
      "gO",
      "<CMD>FzfLua lsp_document_symbols<CR>",
      desc = "Open symbols",
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
            open = false,
          }, function()
            vim.cmd([[
            :FzfLua loclist
          ]])
          end)
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
            open = false,
          }, function()
            vim.cmd([[
            :FzfLua quickfix
          ]])
          end)
        end
      end,
      desc = "Open unstaged hunks in workspace",
    },
  },
})
