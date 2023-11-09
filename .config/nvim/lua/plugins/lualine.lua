local function filetype()
  return vim.bo.filetype
end

local function fileencoding()
  return vim.bo.fileencoding
end

local function fileencoding_color(_)
  if fileencoding() ~= "utf-8" then
    return "ErrorMsg"
  else
    return nil
  end
end

local function fileformat()
  return vim.bo.fileformat
end

local function fileformat_color(_)
  if fileformat() ~= "unix" then
    return "ErrorMsg"
  else
    return nil
  end
end

local function eol()
  if vim.bo.endofline then
    return "eol"
  else
    return "NOEOL"
  end
end

local function eol_color(_)
  if eol() ~= "eol" then
    return "ErrorMsg"
  else
    return nil
  end
end

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        icons_enabled = false,
        theme = "auto",
        section_separators = "",
        component_separators = "",
      },
      sections = {
        lualine_a = { "%f%m%r%h%w" },
        lualine_b = { "diagnostics" },
        lualine_c = {},
        lualine_x = {
          filetype,
          { fileencoding, color = fileencoding_color },
          { fileformat, color = fileformat_color },
          { eol, color = eol_color },
        },
        lualine_y = { "%5l:%-5c" },
        lualine_z = { "%3p%%" },
      },
    },
  },
}
