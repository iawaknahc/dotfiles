return {
  {
    "ibhagwan/fzf-lua",
    enabled = true,
    cmd = { "FzfLua" },
    keys = {
      -- Inspired by Helix space mode f
      {
        "<Space>f",
        function()
          require("fzf-lua").git_files()
        end,
        desc = "Open file in the current project",
      },
      -- Inspired by Helix space mode b
      {
        "<Space>b",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Pick from open buffers",
      },
      {
        "<Space>:",
        function()
          require("fzf-lua").commands()
        end,
        desc = "Fuzzy search commands",
      },
      {
        "<Space>j",
        function()
          require("fzf-lua").jumps()
        end,
        desc = "Pick from jumplist",
      },
      {
        "<Space>g",
        function()
          require("fzf-lua").live_grep()
        end,
        desc = "Live grep in the current project",
      },
      {
        "<Space>/",
        function()
          require("fzf-lua").lgrep_curbuf()
        end,
        desc = "Live grep in the current buffer",
      },
      {
        "<Space>l",
        function()
          require("fzf-lua").blines()
        end,
        desc = "Fuzzy search the lines in the current buffer",
      },
      {
        "<Space>L",
        function()
          require("fzf-lua").lines()
        end,
        desc = "Fuzzy search all lines in open buffers",
      },

      -- Helix space mode usually opens pickers.
      -- Helix also has goto mode i to "go to implementation".
      -- Since here we are opening a picker, so this should be a space mode keymap.
      {
        "<Space>i",
        function()
          require("fzf-lua").lsp_implementations()
        end,
        desc = "Open implementations of the interface under the cursor",
      },
      -- r stands for references.
      -- When this is used on a function,
      -- the results are similar to listing incoming calls.
      -- In a future release of neovim, there is a default mapping gr
      -- that does the same thing with the quickfix list.
      -- See https://github.com/neovim/neovim/pull/28500
      {
        "<Space>r",
        function()
          require("fzf-lua").lsp_references()
        end,
        desc = "Open references to the symbol under the cursor",
      },
      -- c stands for incoming "c"alls.
      {
        "<Space>c",
        function()
          require("fzf-lua").lsp_incoming_calls()
        end,
        desc = "Open incoming calls to the function under the cursor",
      },
      -- C stands for outgoing "c"alls.
      -- It is C because outgoing calls are less common.
      {
        "<Space>C",
        function()
          require("fzf-lua").lsp_outgoing_calls()
        end,
        desc = "Open outgoing calls from the function under the cursor",
      },
      -- s stands for "s"ymbols.
      {
        "<Space>s",
        function()
          require("fzf-lua").lsp_document_symbols()
        end,
        desc = "Open symbols in the current buffer",
      },
      {
        "<Space>S",
        function()
          require("fzf-lua").lsp_live_workspace_symbols()
        end,
        desc = "Open live symbols in workspace",
      },

      -- Diagnostics is preferred over loclist because it supports severity.
      --vim.keymap.set('n', '<Space>l', function() require('telescope.builtin').loclist({ show_line = false }) end)
      -- Inspired by Helix space mode d
      {
        "<Space>d",
        function()
          require("fzf-lua").diagnostics_document()
        end,
        desc = "Open diagnostics of the current buffer",
      },
      {
        "<Space>D",
        function()
          require("fzf-lua").diagnostics_workspace()
        end,
        desc = "Open diagnostics in workspace",
      },
    },
    config = function()
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
        defaults = {
          git_icons = false,
          file_icons = false,
        },
        lsp = {
          symbols = {
            symbol_style = 3,
          },
        },
      })
    end,
  },
}
