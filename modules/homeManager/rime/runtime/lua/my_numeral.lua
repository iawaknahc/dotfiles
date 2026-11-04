---@class NumeralConfiguration
---@field name string
---@field numerals { [0]: string, [1]: string, [2]: string, [3]: string, [4]: string, [5]: string, [6]: string, [7]: string, [8]: string, [9]: string }
---@field digits_per_group integer
---@field skip_numeral_for_ten boolean
---@field supported_subgroups string[]
---@field supported_groups string[]

---@type NumeralConfiguration[]
local numeral_configurations = {
  {
    name = "香港小寫",
    numerals = {
      [0] = "零",
      "一",
      "二",
      "三",
      "四",
      "五",
      "六",
      "七",
      "八",
      "九",
    },
    digits_per_group = 4,
    skip_numeral_for_ten = true,
    supported_groups = {
      "",
      "萬",
      "億",
      "萬億",
    },
    supported_subgroups = {
      "",
      "十",
      "百",
      "千",
    },
  },
  {
    name = "香港大寫",
    numerals = {
      [0] = "零",
      "壹",
      "貳",
      "參",
      "肆",
      "伍",
      "陸",
      "柒",
      "捌",
      "玖",
    },
    digits_per_group = 4,
    skip_numeral_for_ten = true,
    supported_groups = {
      "",
      "萬",
      "億",
      "萬億",
    },
    supported_subgroups = {
      "",
      "拾",
      "佰",
      "仟",
    },
  },
  {
    name = "香港支票",
    numerals = {
      [0] = "零",
      "壹",
      "貳",
      "參",
      "肆",
      "伍",
      "陸",
      "柒",
      "捌",
      "玖",
    },
    digits_per_group = 4,
    skip_numeral_for_ten = false,
    supported_groups = {
      "",
      "萬",
      "億",
      "萬億",
    },
    supported_subgroups = {
      "",
      "拾",
      "佰",
      "仟",
    },
  },
}

-- Return true if STR starts with PREFIX.
---@param str string
---@param prefix string
---@return boolean
local function has_prefix(str, prefix)
  return string.sub(str, 1, #prefix) == prefix
end

-- Split S into groups with each group having N characters.
--- @param s string
--- @param n integer
--- @return string[]
local function split_into_group(s, n)
  local out = {}
  while string.len(s) > 0 do
    local group = string.sub(s, -n, -1)
    table.insert(out, group)
    s = string.sub(s, 1, -(n + 1))
  end
  return out
end

-- Format a group of 4 digits.
-- Examples
-- 0    => ""
-- 0000 => ""
-- 1    => 1
-- 0001 => 01
-- 0100 => 0100
--- @param group string
--- @param config NumeralConfiguration
--- @return string
local function format_group(group, config)
  local out = ""
  local digits = split_into_group(group, 1)
  for digit_idx, digit in ipairs(digits) do
    local digit_value = tonumber(digit, 10)
    if digit_value == 0 then
      -- Non-trailing zeros are collapsed into 1 zero.
      if out ~= "" and not has_prefix(out, config.numerals[0]) then
        out = config.numerals[0] .. out
      end
    else
      local suffix = config.supported_subgroups[digit_idx]
      local numeral = config.numerals[digit_value]
      local skip_numeral = #digits == 2 and digit_idx == 2 and digit_value == 1 and config.skip_numeral_for_ten
      if skip_numeral then
        out = suffix .. out
      else
        out = numeral .. suffix .. out
      end
    end
  end
  return out
end

---@param input string
---@param config NumeralConfiguration
---@return string|nil
local function format_numeral(input, config)
  local groups = split_into_group(input, config.digits_per_group)
  if #groups > #config.supported_groups then
    return nil
  end

  local out = ""
  for group_idx, group in ipairs(groups) do
    local result = format_group(group, config)
    if result ~= "" then
      local group_suffix = config.supported_groups[group_idx]
      out = result .. group_suffix .. out
    elseif out ~= "" and not has_prefix(out, config.numerals[0]) then
      out = config.numerals[0] .. out
    end
  end

  if out == "" and input ~= "" then
    out = config.numerals[0]
  end

  return out
end

---@param input string
---@return { candidate: string, comment: string }[]
local function format_numerals(input)
  local out = {}
  for _, config in ipairs(numeral_configurations) do
    local result = format_numeral(input, config)
    if result == nil then
      table.insert(out, {
        candidate = "數值過大",
        comment = config.name,
      })
    else
      table.insert(out, {
        candidate = result,
        comment = config.name,
      })
    end
  end
  return out
end

---@param input string
---@return string
local function sanitize_input(input)
  -- Strip the decimal point and trailing digits.
  input = string.gsub(input, "%.%d*$", "")
  -- Strip all non-digits.
  input = string.gsub(input, "[^%d]", "")
  -- Strip leading zeros, and pay attention to keep "0".
  input = string.gsub(string.sub(input, 1, -2), "^0+", "") .. string.sub(input, -1, -1)
  return input
end

local M = {}
M.format_numerals = format_numerals
M.sanitize_input = sanitize_input
return M
