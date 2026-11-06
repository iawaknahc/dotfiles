---@param str string
---@param i integer
---@return boolean
local function is_consonant(str, i)
  local ch = string.sub(str, i, i)
  if ch == "a" or ch == "e" or ch == "i" or ch == "o" or ch == "u" then
    return false
  end
  if ch == "y" then
    return i == 1 or i == -#str or not is_consonant(str, i - 1)
  end
  return true
end

---@param str string
---@return integer
local function measure(str)
  -- [C](VC){m}[V]
  local m = 0
  local i = 1
  -- Skip leading consonants
  while i <= #str do
    if is_consonant(str, i) then
      i = i + 1
    else
      break
    end
  end

  while i <= #str do
    local v = 0
    local c = 0
    while i <= #str do
      if not is_consonant(str, i) then
        i = i + 1
        v = v + 1
      else
        break
      end
    end
    while i <= #str do
      if is_consonant(str, i) then
        i = i + 1
        c = c + 1
      else
        break
      end
    end

    if v > 0 and c > 0 then
      m = m + 1
    else
      break
    end
  end

  return m
end

---@param str string
---@param suffix string
---@return string|nil
local function get_stem(str, suffix)
  if #str < #suffix then
    return nil
  end
  if string.sub(str, -#suffix) == suffix then
    return string.sub(str, 1, -#suffix - 1)
  end
  return nil
end

---@param str string
---@param suffix string
---@return boolean
local function ends_with(str, suffix)
  if #str < #suffix then
    return false
  end
  return string.sub(str, -#suffix) == suffix
end

---@param str string
---@return boolean
local function contains_vowel(str)
  for i = 1, #str do
    if not is_consonant(str, i) then
      return true
    end
  end
  return false
end

---@param str string
---@return boolean
local function ends_with_a_double_consonant(str)
  if #str < 2 then
    return false
  end
  return string.sub(str, -1, -1) == string.sub(str, -2, -2) and is_consonant(str, -1)
end

---@param str string
---@return boolean
local function star_o(str)
  if #str < 3 then
    return false
  end
  local c2 = string.sub(str, -1, -1)
  return is_consonant(str, -3)
    and not is_consonant(str, -2)
    and is_consonant(str, -1)
    and (c2 ~= "w" and c2 ~= "x" and c2 ~= "y")
end

---@param str string
---@return string
local function step1a(str)
  if ends_with(str, "sses") then
    str = string.sub(str, 1, -3)
  elseif ends_with(str, "ies") then
    str = string.sub(str, 1, -3)
  elseif ends_with(str, "ss") then
    -- no-op
  elseif ends_with(str, "s") then
    str = string.sub(str, 1, -2)
  end
  return str
end

---@param str string
---@return string
local function step1b(str)
  local do_additional_work
  local stem
  stem = get_stem(str, "eed")
  if stem ~= nil then
    if measure(stem) > 0 then
      str = string.sub(str, 1, -2)
    end
  else
    stem = get_stem(str, "ed")
    if stem ~= nil then
      if contains_vowel(stem) then
        str = stem
        do_additional_work = true
      end
    else
      stem = get_stem(str, "ing")
      if stem ~= nil then
        if contains_vowel(stem) then
          str = stem
          do_additional_work = true
        end
      end
    end
  end
  -- Add stem ~= nil checking to make the typechecker happy.
  if do_additional_work and stem ~= nil then
    if ends_with(str, "at") or ends_with(str, "bl") or ends_with(str, "iz") then
      str = str .. "e"
    elseif
      ends_with_a_double_consonant(stem)
      and not (ends_with(stem, "l") or ends_with(stem, "s") or ends_with(stem, "z"))
    then
      str = string.sub(stem, 1, -2)
    elseif measure(stem) == 1 and star_o(stem) then
      str = stem .. "e"
    end
  end
  return str
end

---@param str string
---@return string
local function step1c(str)
  local stem = get_stem(str, "y")
  if stem ~= nil then
    if contains_vowel(stem) then
      str = stem .. "i"
    end
  end
  return str
end

local step2_rules = {
  { "ational", "ate" },
  { "tional", "tion" },
  { "enci", "ence" },
  { "anci", "ance" },
  { "izer", "ize" },

  -- Match the C implementation rather than the paper.
  { "bli", "ble" },
  -- { "abli", "able" },

  { "alli", "al" },
  { "entli", "ent" },
  { "eli", "e" },
  { "ousli", "ous" },
  { "ization", "ize" },
  { "ation", "ate" },
  { "ator", "ate" },
  { "alism", "al" },
  { "iveness", "ive" },
  { "fulness", "ful" },
  { "ousness", "ous" },
  { "aliti", "al" },
  { "iviti", "ive" },
  { "biliti", "ble" },

  -- Match the C implementation
  { "logi", "log" },
}

---@param str string
---@return string
local function step2(str)
  for _, rule in ipairs(step2_rules) do
    local suffix = rule[1]
    local replacement = rule[2]
    local stem = get_stem(str, suffix)
    if stem ~= nil then
      if measure(stem) > 0 then
        str = stem .. replacement
      end
      break
    end
  end
  return str
end

local step3_rules = {
  { "icate", "ic" },
  { "ative", "" },
  { "alize", "al" },
  { "iciti", "ic" },
  { "ical", "ic" },
  { "ful", "" },
  { "ness", "" },
}

---@param str string
---@return string
local function step3(str)
  for _, rule in ipairs(step3_rules) do
    local suffix = rule[1]
    local replacement = rule[2]
    local stem = get_stem(str, suffix)
    if stem ~= nil then
      if measure(stem) > 0 then
        str = stem .. replacement
      end
      break
    end
  end
  return str
end

local step4_rules = {
  { "al", nil },
  { "ance", nil },
  { "ence", nil },
  { "er", nil },
  { "ic", nil },
  { "able", nil },
  { "ible", nil },
  { "ant", nil },
  { "ement", nil },
  { "ment", nil },
  { "ent", nil },
  {
    "ion",
    ---@param stem string
    ---@return boolean
    function(stem)
      return ends_with(stem, "s") or ends_with(stem, "t")
    end,
  },
  { "ou", nil },
  { "ism", nil },
  { "ate", nil },
  { "iti", nil },
  { "ous", nil },
  { "ive", nil },
  { "ize", nil },
}

---@param str string
---@return string
local function step4(str)
  for _, rule in ipairs(step4_rules) do
    local suffix = rule[1]
    local additional_condition = rule[2]
    local stem = get_stem(str, suffix)
    if stem ~= nil then
      if measure(stem) > 1 then
        if additional_condition == nil or additional_condition(stem) then
          str = stem
        end
      end
      break
    end
  end
  return str
end

---@param str string
---@return string
local function step5a(str)
  local stem = get_stem(str, "e")
  if stem ~= nil then
    local m = measure(stem)
    if m > 1 or (m == 1 and not star_o(stem)) then
      str = stem
    end
  end
  return str
end

---@param str string
---@return string
local function step5b(str)
  if ends_with_a_double_consonant(str) and ends_with(str, "l") and measure(str) > 1 then
    str = string.sub(str, 1, -2)
  end
  return str
end

---@param str string
---@return string
local function porter(str)
  -- Match the C implementation
  if #str < 3 then
    return str
  end

  str = step1a(str)
  str = step1b(str)
  str = step1c(str)
  str = step2(str)
  str = step3(str)
  str = step4(str)
  str = step5a(str)
  str = step5b(str)
  return str
end

return porter
