require("lz.n").load({
  "lualine.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    require("lualine").setup({
      options = {
        icons_enabled = false,
        theme = "catppuccin-mocha",
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
        lualine_y = {
          "%{'byte:'}%5l:%-3c",
          "%{'cell:'}%5l:%-3v",
          function()
            local getpos_result = vim.fn.getpos(".")
            local cursor_row_1indexing = getpos_result[2]
            local cursor_col_1indexing = getpos_result[3]

            local winid = vim.api.nvim_get_current_win()
            local getwininfo_result = vim.fn.getwininfo(winid)[1]

            local screenpost_result = vim.fn.screenpos(0, cursor_row_1indexing, cursor_col_1indexing)

            local screen_row = screenpost_result.row
            local screen_col = screenpost_result.col - getwininfo_result.textoff

            return string.format("screen:%5d:%-3d", screen_row, screen_col)
          end,
        },
        lualine_z = { "%o/%{getfsize(expand(@%))}", "%3p%%" },
      },
    })
  end,
})
