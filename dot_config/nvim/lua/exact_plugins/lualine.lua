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

local function navic()
  local status, n = pcall(require, "nvim-navic")
  if status then
    if n.is_available() then
      return n.get_location()
    end
  end
  return ""
end

local function navic_cond()
  local status, n = pcall(require, "nvim-navic")
  if status then
    return n.is_available()
  end
  return false
end

return {
  {
    "nvim-lualine/lualine.nvim",
    enabled = true,
    -- rg "lazy = false" shows eagerly loaded plugins.
    lazy = false,
    opts = {
      options = {
        icons_enabled = false,
        theme = "auto",
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
      winbar = {
        lualine_c = { { navic, cond = navic_cond, draw_empty = true } },
      },
    },
  },
}
