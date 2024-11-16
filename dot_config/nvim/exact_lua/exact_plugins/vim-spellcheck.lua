return {
  {
    "inkarkat/vim-spellcheck",
    enabled = true,
    cmd = { "SpellCheck" },
    dependencies = {
      "inkarkat/vim-ingo-library",
    },
    keys = {
      {
        "zq", "<Cmd>SpellCheck! | copen <CR>",
        desc = ":SpellCheck! | copen",
      },
    },
  },
}
