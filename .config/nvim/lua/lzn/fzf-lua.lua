require("lz.n").load({
  "fzf-lua",
  enabled = true,
  -- I find it starts too late if we load it at DeferredUIEnter.
  lazy = false,
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

    -- Keep only the keymaps that I actually use.
    -- For others, Use <Space><Space> to run :FzfLua, and then type the name to invoke the picker fuzzily.
    vim.keymap.set("n", "<Space><Space>", "<CMD>FzfLua<CR>", {
      desc = ":FzfLua",
    })

    -- Inspired by Helix space mode f
    vim.keymap.set("n", "<Space>f", "<CMD>FzfLua git_files<CR>", {
      desc = ":FzfLua git_files",
    })
    vim.keymap.set("n", "<Space>F", "<CMD>FzfLua files<CR>", {
      desc = ":FzfLua files",
    })

    -- Inspired by Helix space mode b
    vim.keymap.set("n", "<Space>b", "<CMD>FzfLua buffers<CR>", {
      desc = ":FzfLua buffers",
    })

    vim.keymap.set("n", "<Space>l", "<CMD>FzfLua loclist<CR>", {
      desc = ":FzfLua loclist",
    })
    vim.keymap.set("n", "<Space>q", "<CMD>FzfLua quickfix<CR>", {
      desc = ":FzfLua quickfix",
    })

    -- Inspired by Helix space mode d
    vim.keymap.set("n", "<Space>d", function()
      vim.diagnostic.setloclist()
    end, {
      desc = ":lua vim.diagnostic.setloclist()",
    })
    -- Inspired by Helix space mode D
    vim.keymap.set("n", "<Space>D", "<CMD>FzfLua diagnostics_workspace<CR>", {
      desc = ":FzfLua diagnostics_workspace",
    })

    vim.keymap.set("n", "<Space>h", function()
      local ok, gitsigns = pcall(require, "gitsigns")
      if ok then
        local buf = 0
        gitsigns.setqflist(buf, {
          use_location_list = true,
          open = true,
        })
      end
    end, { desc = "Gitsigns: unstaged hunks to loclist" })

    vim.keymap.set("n", "<Space>H", function()
      local ok, gitsigns = pcall(require, "gitsigns")
      if ok then
        gitsigns.setqflist("all", {
          use_location_list = false,
          open = true,
        })
      end
    end, { desc = "Gitsigns: unstaged hunks to qflist" })
  end,
})
