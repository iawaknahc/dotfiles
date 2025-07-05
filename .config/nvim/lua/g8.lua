local M = {}

---@param codepoint integer
---@return integer[]
local function codepoint_to_utf8(codepoint)
  local bit = require("bit")
  if codepoint < 0 then
    error("Invalid Unicode codepoint: " .. codepoint)
  end
  if codepoint <= 0x7F then
    return { codepoint }
  elseif codepoint <= 0x7FF then
    local byte1 = 0xC0 + bit.rshift(codepoint, 6)
    local byte2 = 0x80 + bit.band(codepoint, 0x3F)
    return { byte1, byte2 }
  elseif codepoint <= 0xFFFF then
    local byte1 = 0xE0 + bit.rshift(codepoint, 12)
    local byte2 = 0x80 + bit.band(bit.rshift(codepoint, 6), 0x3F)
    local byte3 = 0x80 + bit.band(codepoint, 0x3F)
    return { byte1, byte2, byte3 }
  elseif codepoint <= 0x10FFFF then
    local byte1 = 0xF0 + bit.rshift(codepoint, 18)
    local byte2 = 0x80 + bit.band(bit.rshift(codepoint, 12), 0x3F)
    local byte3 = 0x80 + bit.band(bit.rshift(codepoint, 6), 0x3F)
    local byte4 = 0x80 + bit.band(codepoint, 0x3F)
    return { byte1, byte2, byte3, byte4 }
  else
    error("Invalid Unicode codepoint: " .. codepoint)
  end
end

---@param codepoint integer
---@return integer[]
local function codepoint_to_utf16be(codepoint)
  local bit = require("bit")
  if codepoint < 0 then
    error("Invalid Unicode codepoint: " .. codepoint)
  end
  if codepoint <= 0xFFFF then
    local high = bit.band(bit.rshift(codepoint, 8), 0xFF)
    local low = bit.band(codepoint, 0xFF)
    return { high, low }
  elseif codepoint <= 0x10FFFF then
    codepoint = codepoint - 0x10000
    local high_surrogate = 0xD800 + bit.rshift(codepoint, 10)
    local low_surrogate = 0xDC00 + bit.band(codepoint, 0x3FF)
    local h1 = bit.band(bit.rshift(high_surrogate, 8), 0xFF)
    local h2 = bit.band(high_surrogate, 0xFF)
    local l1 = bit.band(bit.rshift(low_surrogate, 8), 0xFF)
    local l2 = bit.band(low_surrogate, 0xFF)
    return { h1, h2, l1, l2 }
  else
    error("Invalid Unicode codepoint: " .. codepoint)
  end
end

---@param codepoint integer
---@return integer[]
local function codepoint_to_utf16le(codepoint)
  local bit = require("bit")
  if codepoint < 0 then
    error("Invalid Unicode codepoint: " .. codepoint)
  end
  if codepoint <= 0xFFFF then
    local high = bit.band(bit.rshift(codepoint, 8), 0xFF)
    local low = bit.band(codepoint, 0xFF)
    return { low, high }
  elseif codepoint <= 0x10FFFF then
    codepoint = codepoint - 0x10000
    local high_surrogate = 0xD800 + bit.rshift(codepoint, 10)
    local low_surrogate = 0xDC00 + bit.band(codepoint, 0x3FF)
    local h1 = bit.band(bit.rshift(high_surrogate, 8), 0xFF)
    local h2 = bit.band(high_surrogate, 0xFF)
    local l1 = bit.band(bit.rshift(low_surrogate, 8), 0xFF)
    local l2 = bit.band(low_surrogate, 0xFF)
    return { h2, h1, l2, l1 }
  else
    error("Invalid Unicode codepoint: " .. codepoint)
  end
end

---@param codepoint integer
---@return integer[]
local function codepoint_to_utf32be(codepoint)
  local bit = require("bit")
  if codepoint < 0 or codepoint > 0x10FFFF then
    error("Invalid Unicode codepoint: " .. codepoint)
  end
  local b1 = bit.band(bit.rshift(codepoint, 24), 0xFF)
  local b2 = bit.band(bit.rshift(codepoint, 16), 0xFF)
  local b3 = bit.band(bit.rshift(codepoint, 8), 0xFF)
  local b4 = bit.band(codepoint, 0xFF)
  return { b1, b2, b3, b4 }
end

---@param codepoint integer
---@return integer[]
local function codepoint_to_utf32le(codepoint)
  local bit = require("bit")
  if codepoint < 0 or codepoint > 0x10FFFF then
    error("Invalid Unicode codepoint: " .. codepoint)
  end
  local b1 = bit.band(bit.rshift(codepoint, 24), 0xFF)
  local b2 = bit.band(bit.rshift(codepoint, 16), 0xFF)
  local b3 = bit.band(bit.rshift(codepoint, 8), 0xFF)
  local b4 = bit.band(codepoint, 0xFF)
  return { b4, b3, b2, b1 }
end

---@param byte integer
---@return string
local function byte_to_g8_repr(byte)
  return string.format("%02x", byte)
end

---@param byte_sequence integer[]
---@return string
local function byte_sequence_to_g8_repr(byte_sequence)
  local out = {}
  for _, byte in ipairs(byte_sequence) do
    table.insert(out, byte_to_g8_repr(byte))
  end
  return table.concat(out, " ")
end

function M.g8()
  local encoding = vim.o.encoding
  if encoding == nil or encoding == "" then
    encoding = "utf-8"
  end
  if encoding ~= "utf-8" then
    vim.notify("g8 does not work when 'encoding' is not utf-8", vim.log.levels.WARN)
    return
  end

  local fileencoding = vim.bo.fileencoding
  if fileencoding == nil or fileencoding == "" then
    fileencoding = "utf-8"
  end
  local fns = {
    ["utf-8"] = codepoint_to_utf8,
    ["ucs-2"] = codepoint_to_utf16be,
    ["ucs-2le"] = codepoint_to_utf16le,
    ["utf-16"] = codepoint_to_utf16be,
    ["utf-16le"] = codepoint_to_utf16le,
    ["ucs-4"] = codepoint_to_utf32be,
    ["ucs-4le"] = codepoint_to_utf32le,
  }
  local fn = fns[fileencoding]
  if fn == nil then
    vim.notify("unsupported fileencoding: " .. fileencoding, vim.log.levels.WARN)
    return
  end

  local ga = vim.fn.execute("normal! ga")
  -- Extract the output of ga into codepoints.
  -- We have to use ga because it natively supports combining characters.
  -- An example of the output of ga looks like
  --
  -- <a>  97,  Hex 61,  Octal 141 < ̀> 768, Hex 0300, Octal 1400 < ́> 769, Hex 0301, Octal 1401
  ---@type integer[]
  local codepoints = {}
  for _, match in ipairs(vim.fn.matchstrlist({ ga }, [[\vHex \zs\x+\ze]])) do
    ---@type string
    local hex = match.text
    local codepoint = vim.fn.str2nr(hex, 16)
    table.insert(codepoints, codepoint)
  end

  ---@type string[]
  local list_of_byte_sequence = {}
  for _, codepoint in ipairs(codepoints) do
    local byte_sequence = fn(codepoint)
    local g8_repr = byte_sequence_to_g8_repr(byte_sequence)
    table.insert(list_of_byte_sequence, g8_repr)
  end

  local out = table.concat(list_of_byte_sequence, " + ")
  -- Use print to output to messages, like the builtin g8.
  print(out)
end

return M
