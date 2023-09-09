return {
  {
    "ms-jpq/coq_nvim",
    branch = "coq",
    init = function()
      local coq_settings = {}
      coq_settings["auto_start"] = "shut-up"
      coq_settings["display.icons.mode"] = "none"
      -- Disable the missing snippets warning.
      -- https://github.com/ms-jpq/coq_nvim/blob/coq/docs/SNIPS.md#et-al
      coq_settings["clients.snippets.warn"] = {}
      vim.g.coq_settings = coq_settings
    end,
  },
}
