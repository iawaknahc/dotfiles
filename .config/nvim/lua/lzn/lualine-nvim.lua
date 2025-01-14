local theme = {
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
}

local function filetype()
  return vim.bo.filetype
end

local function fileencoding()
  return vim.bo.fileencoding
end

local function fileencoding_color()
  if fileencoding() ~= "utf-8" then
    return "ErrorMsg"
  end
  return nil
end

local function fileformat()
  return vim.bo.fileformat
end

local function fileformat_color()
  if fileformat() ~= "unix" then
    return "ErrorMsg"
  end
  return nil
end

local function eol()
  if vim.bo.endofline then
    return "eol"
  end
  return "NOEOL"
end

local function eol_color()
  if eol() ~= "eol" then
    return "ErrorMsg"
  end
  return nil
end

require("lz.n").load {
  "lualine.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    require("lualine").setup {
      options = {
        icons_enabled = false,
        theme = theme,
        section_separators = "",
        component_separators = "",
      },
      sections = {
        lualine_a = { "%f%m%r%h%w" },
        lualine_b = { "diff" },
        lualine_c = { "diagnostics" },
        lualine_x = {
          filetype,
          { fileencoding, color = fileencoding_color },
          { fileformat, color = fileformat_color },
          { eol, color = eol_color },
        },
        lualine_y = { "%5l:%-5c" },
        lualine_z = { "%3p%%" },
      },
    }
  end,
}
