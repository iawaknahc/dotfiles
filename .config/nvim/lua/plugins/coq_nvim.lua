return {
  {
    'ms-jpq/coq_nvim',
    branch = 'coq',
    init = function()
      local coq_settings = {}
      coq_settings["auto_start"] = "shut-up"
      coq_settings["display.icons.mode"] = "none"
      vim.g.coq_settings = coq_settings
    end,
  },
}
