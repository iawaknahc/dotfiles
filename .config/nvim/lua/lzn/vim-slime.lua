require("lz.n").load({
  "vim-slime",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  before = function()
    vim.g.slime_no_mappings = 1
    vim.g.slime_target = "neovim"
    vim.g.slime_bracketed_paste = 1

    -- Python 3.13 has a new interactive interpreter enabled by default.
    -- https://docs.python.org/3/whatsnew/3.13.html#whatsnew313-better-interactive-interpreter
    -- The interpreter by default is not in paste mode.
    -- It will auto indent pasted text, causing the indentation to go wrong.
    -- To work around this, you need to first place the interpreter into paste mode by pressing F3.
    -- However, even in paste mode, code is not executed until you exit paste mode.
    -- This really breaks the workflow of vim-slime.
    --
    -- The best solution at the moment is to use the traditional interpreter with `PYTHON_BASIC_REPL=1 python3`.
  end,
  after = function()
    vim.g.slime_suggest_default = 1

    vim.keymap.set("x", "<Leader>r", "<Plug>SlimeRegionSend", {
      remap = true,
      silent = false,
      desc = "Slime: Send selection",
    })
    vim.keymap.set("n", "<Leader>r", "<Plug>SlimeMotionSend", {
      remap = true,
      silent = false,
      desc = "Slime: Send {motion}",
    })
    vim.keymap.set("n", "<Leader>rr", "<Plug>SlimeLineSend", {
      remap = true,
      silent = false,
      desc = "Slime: Send line",
    })
  end,
})
