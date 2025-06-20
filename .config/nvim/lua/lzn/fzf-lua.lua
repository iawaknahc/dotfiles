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

    -- Inspired by Helix space mode D
    vim.keymap.set("n", "<Space>D", "<CMD>FzfLua diagnostics_workspace<CR>", {
      desc = ":FzfLua diagnostics_workspace",
    })
  end,
})
