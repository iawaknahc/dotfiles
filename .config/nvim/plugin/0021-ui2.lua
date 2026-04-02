require("vim._core.ui2").enable({
  enable = true,
  msg = {
    -- There are 3 targets:
    -- cmd: Shown in the cmd.
    -- msg: Shown in the self-dismissing popup.
    -- pager: It is :messages.
    --
    -- If the target is "pager", then the pager is focused, which may be annoying. Therefore, "pager" is never used.
    --
    -- Use g< to view recent messages
    target = "cmd",
    targets = {
      -- LSP notification messages should be shown in self-dismissing popups.
      progress = "msg",
    },
  },
})
