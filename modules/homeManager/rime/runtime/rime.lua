local numeral = require("my_numeral")
local snippet = require("my_snippet")
--- @type { common_in_hong_kong: string[], unicode_cjk_extension_ranges: [integer, integer][] }
local unicode_cjk_extension_filter_data = require("unicode_cjk_extension_filter_data")
local FTSIndex = require("my_full_text_search")

-- Get the path to the Rime user directory.
-- Tested it works on macOS and Hamster.
---@return string|nil
local function get_rime_home()
  ---@type string|nil
  local home = nil
  for path in string.gmatch(package.path, "([^;]+)") do
    local suffix = "/Rime/lua/?.lua"
    if string.sub(path, -#suffix) == suffix then
      home = string.sub(path, 1, -#suffix - 1) .. "/Rime"
    end
  end
  return home
end

---@param str string
---@param prefix string
---@return boolean
local function has_prefix(str, prefix)
  return string.sub(str, 1, #prefix) == prefix
end

---@param cps string
---@return string
local function cps_to_string(cps)
  local codepoints = {}
  for codepoint_str in string.gmatch(cps, "[^ ]+") do
    local codepoint = tonumber(codepoint_str, 16)
    if codepoint ~= nil then
      table.insert(codepoints, codepoint)
    end
  end
  if table.unpack ~= nil then
    return utf8.char(table.unpack(codepoints))
  else
    return utf8.char(unpack(codepoints))
  end
end

-- This has to be a global variable, not a property on env.
-- If it were a property on env, the index gets rebuilt very often.
-- And the rebuild takes time.
-- The index contains many tables, adding more workload to the garbage collector.
---@type FTSIndex|nil
UNICODE_TRANSLATOR_FTS_INDEX = nil

---@param path string
---@return fun(): FTSDocument|nil
local function iterate_unicode_tsv(path)
  local iter = io.lines(path)
  return function()
    for line in iter do
      ---@type string|nil
      local title
      ---@type string|nil
      local content
      local num_fields = 0
      for field in string.gmatch(line, "[^\t]+") do
        if num_fields == 0 then
          title = field
        elseif num_fields == 1 then
          content = field
        else
          error("Expected only 2 fields per line")
        end
        num_fields = num_fields + 1
      end
      if title == nil or content == nil then
        error("Less than 2 fields")
      end
      return { title = title, content = content }
    end
  end
end

unicode_translator = {
  init = function()
    if UNICODE_TRANSLATOR_FTS_INDEX == nil then
      local home = get_rime_home()
      if home ~= nil then
        local iter = iterate_unicode_tsv(home .. "/unicode.tsv")
        UNICODE_TRANSLATOR_FTS_INDEX = FTSIndex.new()
        for document in iter do
          UNICODE_TRANSLATOR_FTS_INDEX:add_document(document)
        end
        UNICODE_TRANSLATOR_FTS_INDEX:finish_indexing()
      end
    end
  end,
  ---@param input string
  ---@param segment Segment
  func = function(input, segment)
    if UNICODE_TRANSLATOR_FTS_INDEX == nil then
      return
    end

    if not segment:has_tag("unicode") then
      return
    end
    ---@type integer|nil
    local base = nil
    if has_prefix(input, "U+") or has_prefix(input, "Ux") then
      base = 16
    elseif has_prefix(input, "Ud") then
      base = 10
    elseif has_prefix(input, "Ub") then
      base = 2
    elseif has_prefix(input, "Uo") then
      base = 8
    end

    local query = string.gsub(string.sub(input, 2), "_", " ")
    local documents = UNICODE_TRANSLATOR_FTS_INDEX:search(query, 9 * 10)
    for _, document in ipairs(documents) do
      local text = cps_to_string(document.title)
      local comment = document.content
      yield(Candidate("unicode", segment.start, segment._end, text, comment))
    end
  end,
}

---@param input string
---@param segment Segment
function numeral_translator(input, segment)
  if not segment:has_tag("numeral") then
    return
  end

  -- Strip the prefix D.
  input = string.sub(input, 2)
  local raw_input_without_prefix = input
  input = numeral.sanitize_input(input)
  if input == "" then
    return
  end

  for _, result in ipairs(numeral.format_numerals(input)) do
    local candidate = Candidate("numeral", segment.start, segment._end, result.candidate, result.comment)
    local preedit = "D" .. numeral.get_preedit(raw_input_without_prefix)
    candidate.preedit = preedit
    yield(candidate)
  end
end

local snippets = {
  { keyword = "today", text = snippet.today, comment = "今日" },
  { keyword = "tomorrow", text = snippet.tomorrow, comment = "聽日" },
  { keyword = "yesterday", text = snippet.yesterday, comment = "尋日" },
  { keyword = "thisweek", text = snippet.this_week, comment = "今星期" },
  { keyword = "nextweek", text = snippet.next_week, comment = "下星期" },
  { keyword = "lastweek", text = snippet.last_week, comment = "上星期" },
  { keyword = "shebangpython", text = snippet.shebang_python, comment = "Python" },
  { keyword = "shebangnushell", text = snippet.shebang_nushell, comment = "Nushell" },
  { keyword = "shebangneovim", text = snippet.shebang_neovim, comment = "Neovim" },
  { keyword = "shebangsh", text = snippet.shebang_sh, comment = "sh" },
  { keyword = "shebangemacs", text = snippet.shebang_emacs, comment = "Emacs" },
}

---@param input string
---@param segment Segment
function snippet_translator(input, segment)
  if not segment:has_tag("abc") then
    return
  end

  if #input < 3 then
    return
  end

  for _, s in ipairs(snippets) do
    if s.keyword:find(input, 1, true) then
      yield(Candidate("snippet", segment.start, segment._end, s.text(), s.comment))
    end
  end
end

-- This filter is an important UX improvement for librime-predict.
-- Without this filter, the candidates populated by librime-predict has no preedit.
-- After committing a candidate, the prediction menu is shown automatically.
-- But without preedit, the underlying application will not consider the input method is doing its job.
-- Key events such as C-n will select the next candidate in the prediction menu AND be handled by the application.
-- This will result in a mess.
--
-- What this filter does is very simple,
-- when the candidate is a prediction candidate,
-- set the preedit to a non-empty string.
-- This will cause Rime appear to the application that it is composing.
--
-- It is not a good idea to set preedit to candidate.text,
-- as you will see the first prediction candidate being filled in the application.
--
-- I also tried setting preedit to U+200B (ZERO WIDTH SPACE).
-- But that will cause the prediction menu to be misplaced by the application.
--
-- So we need a character that is printable and non-intrusive.
-- The underscore character is a good choice here.
---@param input Translation
function prediction_preedit_filter(input)
  for candidate in input:iter() do
    if candidate:get_genuine().type == "prediction" then
      candidate:get_genuine().preedit = "_"
    end
    yield(candidate)
  end
end

---@param text string
---@return boolean
local function is_in_unicode_cjk_extension(text)
  for _, codepoint in utf8.codes(text) do
    for _, r in ipairs(unicode_cjk_extension_filter_data.unicode_cjk_extension_ranges) do
      local lower = r[1]
      local upper = r[2]
      if codepoint >= lower and codepoint <= upper then
        return true
      end
    end
  end
  return false
end

---@param text string
---@return boolean
local function is_common_in_hong_kong(text)
  for _, codepoint in utf8.codes(text) do
    local str = utf8.char(codepoint)
    for _, s in ipairs(unicode_cjk_extension_filter_data.common_in_hong_kong) do
      if s == str then
        return true
      end
    end
  end
  return false
end

---@param input Translation
---@param env Env
function unicode_cjk_extension_filter(input, env)
  local extended_charset = env.engine.context:get_option("extended_charset")
  for candidate in input:iter() do
    -- Always allow the Unicode translator to output anything.
    if candidate:get_genuine().type == "unicode" then
      yield(candidate)
    elseif extended_charset then
      yield(candidate)
    elseif not is_in_unicode_cjk_extension(candidate.text) then
      yield(candidate)
    elseif is_common_in_hong_kong(candidate.text) then
      yield(candidate)
    end
  end
end

reverse_lookup_filter_jyut6ping3 = {
  init = function(env)
    env.jyut6ping3_reverse_lookup_db = ReverseDb("build/jyut6ping3.reverse.bin")
  end,
  ---@param input Translation
  ---@param env Env
  func = function(input, env)
    ---@type ReverseDb
    local jyut6ping3_reverse_lookup_db = env.jyut6ping3_reverse_lookup_db
    for candidate in input:iter() do
      local candidate_type = candidate:get_genuine().type
      local is_prediction = candidate_type == "prediction"
      local is_from_user_input = candidate_type == "table"
        or candidate_type == "user_table"
        or candidate_type == "completion"
        or candidate_type == "phrase"

      local is_from_jyut6ping3 = false
      if is_from_user_input then
        local phrase = candidate:to_phrase()
        is_from_jyut6ping3 = phrase.lang_name == "jyut6ping3"
      end

      if is_prediction or (is_from_user_input and not is_from_jyut6ping3) then
        -- Note that we look up the whole phrase.
        -- When the phrase has more than one character,
        -- the lookup will fail and return an empty string.
        -- We settle with this behavior because
        -- many characters have more than one pronunciations.
        -- Looking up character by character will yield many results.
        -- The comment will be very long and unreadable.
        local result = jyut6ping3_reverse_lookup_db:lookup(candidate:get_genuine().text)
        if result ~= "" then
          candidate.comment = candidate.comment .. " " .. result
        end
      end
      yield(candidate)
    end
  end,
}

---@param cangjie5_code string
---@return string
function humanize_cangjie5_code(cangjie5_code)
  cangjie5_code = string.gsub(cangjie5_code, "a", "日")
  cangjie5_code = string.gsub(cangjie5_code, "b", "月")
  cangjie5_code = string.gsub(cangjie5_code, "c", "金")
  cangjie5_code = string.gsub(cangjie5_code, "d", "木")
  cangjie5_code = string.gsub(cangjie5_code, "e", "水")
  cangjie5_code = string.gsub(cangjie5_code, "f", "火")
  cangjie5_code = string.gsub(cangjie5_code, "g", "土")
  cangjie5_code = string.gsub(cangjie5_code, "h", "竹")
  cangjie5_code = string.gsub(cangjie5_code, "i", "戈")
  cangjie5_code = string.gsub(cangjie5_code, "j", "十")
  cangjie5_code = string.gsub(cangjie5_code, "k", "大")
  cangjie5_code = string.gsub(cangjie5_code, "l", "中")
  cangjie5_code = string.gsub(cangjie5_code, "m", "一")
  cangjie5_code = string.gsub(cangjie5_code, "n", "弓")
  cangjie5_code = string.gsub(cangjie5_code, "o", "人")
  cangjie5_code = string.gsub(cangjie5_code, "p", "心")
  cangjie5_code = string.gsub(cangjie5_code, "q", "手")
  cangjie5_code = string.gsub(cangjie5_code, "r", "口")
  cangjie5_code = string.gsub(cangjie5_code, "s", "尸")
  cangjie5_code = string.gsub(cangjie5_code, "t", "廿")
  cangjie5_code = string.gsub(cangjie5_code, "u", "山")
  cangjie5_code = string.gsub(cangjie5_code, "v", "女")
  cangjie5_code = string.gsub(cangjie5_code, "w", "田")
  cangjie5_code = string.gsub(cangjie5_code, "x", "難")
  cangjie5_code = string.gsub(cangjie5_code, "y", "卜")
  cangjie5_code = string.gsub(cangjie5_code, "z", "重")
  -- For characters with more than one code,
  -- group them with parenthesis.
  if cangjie5_code:find(" ", 1, true) then
    cangjie5_code = "(" .. cangjie5_code .. ")"
  end
  return cangjie5_code
end

reverse_lookup_filter_cangjie5 = {
  init = function(env)
    env.cangjie5_reverse_lookup_db = ReverseDb("build/cangjie5_hk.reverse.bin")
  end,
  ---@param input Translation
  ---@param env Env
  func = function(input, env)
    ---@type ReverseDb
    local cangjie5_reverse_lookup_db = env.cangjie5_reverse_lookup_db
    for candidate in input:iter() do
      local candidate_type = candidate:get_genuine().type
      local is_prediction = candidate_type == "prediction"
      local is_from_user_input = candidate_type == "table"
        or candidate_type == "user_table"
        or candidate_type == "completion"
        or candidate_type == "phrase"

      local is_from_cangjie5 = false
      if is_from_user_input then
        local phrase = candidate:to_phrase()
        is_from_cangjie5 = phrase.lang_name == "cangjie5_hk"
      end

      if is_prediction or (is_from_user_input and not is_from_cangjie5) then
        -- We lookup character by character because
        -- in Cangjie, most characters have only one code.
        -- A phrase having more than one character most of the time
        -- have the same number of reverse lookup codes.
        for _, codepoint in utf8.codes(candidate:get_genuine().text) do
          local character = utf8.char(codepoint)
          local code = cangjie5_reverse_lookup_db:lookup(character)
          if code ~= "" then
            candidate.comment = candidate.comment .. " " .. humanize_cangjie5_code(code)
          else
            candidate.comment = candidate.comment .. " " .. "NULL"
          end
        end
      end
      yield(candidate)
    end
  end,
}
