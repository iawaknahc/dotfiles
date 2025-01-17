require("lz.n").load {
  "fzf-lua",
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
  cmd = "FzfLua",
  keys = {
    -- Inspired by Helix space mode f
    {
      "<Space>f",
      "<CMD>FzfLua git_files<CR>",
      desc = "Open file in the current project",
    },
    -- Inspired by Helix space mode b
    {
      "<Space>b",
      "<CMD>FzfLua buffers<CR>",
      desc = "Pick from open buffers",
    },
    {
      "<Space>:",
      "<CMD>FzfLua commands<CR>",
      desc = "Fuzzy search commands",
    },
    {
      "<Space>j",
      "<CMD>FzfLua jumps<CR>",
      desc = "Pick from jumplist",
    },
    {
      "<Space>g",
      "<CMD>FzfLua live_grep<CR>",
      desc = "Live grep in the current project",
    },
    {
      "<Space>/",
      "<CMD>FzfLua lgrep_curbuf<CR>",
      desc = "Live grep in the current buffer",
    },
    {
      "<Space>l",
      "<CMD>FzfLua blines<CR>",
      desc = "Fuzzy search the lines in the current buffer",
    },
    {
      "<Space>L",
      "<CMD>FzfLua lines<CR>",
      desc = "Fuzzy search all lines in open buffers",
    },

    -- Helix space mode usually opens pickers.
    -- Helix also has goto mode i to "go to implementation".
    -- Since here we are opening a picker, so this should be a space mode keymap.
    {
      "<Space>i",
      "<CMD>FzfLua lsp_implementations<CR>",
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
      "<CMD>FzfLua lsp_references<CR>",
      desc = "Open references to the symbol under the cursor",
    },
    -- c stands for incoming "c"alls.
    {
      "<Space>c",
      "<CMD>FzfLua lsp_incoming_calls<CR>",
      desc = "Open incoming calls to the function under the cursor",
    },
    -- C stands for outgoing "c"alls.
    -- It is C because outgoing calls are less common.
    {
      "<Space>C",
      "<CMD>FzfLua lsp_outgoing_calls<CR>",
      desc = "Open outgoing calls from the function under the cursor",
    },
    -- s stands for "s"ymbols.
    {
      "<Space>s",
      "<CMD>FzfLua lsp_document_symbols<CR>",
      desc = "Open symbols in the current buffer",
    },
    {
      "<Space>S",
      "<CMD>FzfLua lsp_live_workspace_symbols<CR>",
      desc = "Open live symbols in workspace",
    },

    -- Diagnostics is preferred over loclist because it supports severity.
    --vim.keymap.set('n', '<Space>l', function() require('telescope.builtin').loclist({ show_line = false }) end)
    -- Inspired by Helix space mode d
    {
      "<Space>d",
      "<CMD>FzfLua diagnostics_document<CR>",
      desc = "Open diagnostics of the current buffer",
    },
    {
      "<Space>D",
      "<CMD>FzfLua diagnostics_workspace<CR>",
      desc = "Open diagnostics in workspace",
    },
  },
}