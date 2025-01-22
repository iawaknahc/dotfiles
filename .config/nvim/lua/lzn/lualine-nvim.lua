require("lz.n").load {
  "lualine.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    require("lualine").setup {
      options = {
        icons_enabled = false,
        theme = {
          normal = {
            a = "DraculaPurpleBoldInverse",
            b = "DraculaBgLighter",
            c = "DraculaBgLight",
          },
          insert = {
            a = "DraculaGreenBoldInverse",
            b = "DraculaBgLighter",
            c = "DraculaBgLight",
          },
          visual = {
            a = "DraculaYellowBoldInverse",
            b = "DraculaBgLighter",
            c = "DraculaBgLight",
          },
          replace = {
            a = "DraculaRedBoldInverse",
            b = "DraculaBgLighter",
            c = "DraculaBgLight",
          },
          command = {
            a = "DraculaOrangeBoldInverse",
            b = "DraculaBgLighter",
            c = "DraculaBgLight",
          },
          inactive = {
            a = "DraculaBgLightBold",
            b = "DraculaBgLighter",
            c = "DraculaBgLight",
          },
        },
        section_separators = "",
        component_separators = "",
      },
      sections = {
        lualine_a = {
          function()
            local buf = vim.api.nvim_get_current_buf()
            return string.format("b%d", buf)
          end,
          function()
            local win = vim.api.nvim_get_current_win()
            return string.format("w%d", win)
          end,
          "%f%m%r%h%w",
        },
        lualine_b = { "diff" },
        lualine_c = { "diagnostics" },
        lualine_x = {
          "bo:filetype",
          {
            "bo:fileencoding",
            color = function()
              if vim.bo.fileencoding ~= "utf-8" then
                return "ErrorMsg"
              end
              return nil
            end,
          },
          {
            "bo:fileformat",
            color = function()
              if vim.bo.fileformat ~= "unix" then
                return "ErrorMsg"
              end
              return nil
            end,
          },
          {
            function()
              if vim.bo.endofline then
                return "eol"
              end
              return "NOEOL"
            end,
            color = function()
              if not vim.bo.endofline then
                return "ErrorMsg"
              end
              return nil
            end,
          },
        },
        lualine_y = { "%5l:%-3c", "%o/%{getfsize(expand(@%))}" },
        lualine_z = { "%3p%%" },
      },
    }
  end,
}
