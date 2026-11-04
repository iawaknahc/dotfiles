local json = require("json")
local numeral = require("my_numeral")
local snippet = require("my_snippet")
--- @type { common_in_hong_kong: string[], unicode_cjk_extension_ranges: [integer, integer][] }
local unicode_cjk_extension_filter_data = require("unicode_cjk_extension_filter_data")

---@param str string
---@param prefix string
---@return boolean
local function has_prefix(str, prefix)
  return string.sub(str, 1, #prefix) == prefix
end

---@param user_input string
---@return string
local function prepare_fts5_query(user_input)
  local terms = {}
  -- We treat all non-alphabetic characters as separators.
  -- We do this because we are not using query argument binding,
  -- so we want the query terms contain no special characters.
  for term in string.gmatch(user_input, "[a-zA-Z0-9]+") do
    table.insert(terms, term)
  end
  local column_filter = "{name tts} : "
  return column_filter .. table.concat(terms, " ")
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

---@param rows {cps: string, name: string}[]
---@param segment Segment
local function handle_rows(rows, segment)
  for _, row in ipairs(rows) do
    local name = row["name"]
    local cps = row["cps"]
    local str = cps_to_string(cps)
    local candidate = Candidate("unicode", segment.start, segment._end, str, name)
    yield(candidate)
  end
end

---@param cmd string
---@param segment Segment
local function handle_cmd(cmd, segment)
  local handle = io.popen(cmd, "r")
  local stdout = handle:read("*a")
  handle:close()

  local ok, rows = pcall(json.decode, stdout)
  if ok then
    handle_rows(rows --[[@as {cps: string, name: string}[] ]], segment)
  end
end

---@param codepoint integer
---@param segment Segment
local function search_by_codepoint(codepoint, segment)
  if codepoint >= 0 and codepoint <= 0x10FFFF then
    local cmd = string.format(
      [[~/.nix-profile/bin/sqlite3 -json ~/.nix-profile/share/unicode/unicode.sqlite3 "select cps, name, tts from codepoint_sequence where cps = '%04X' limit 1;"]],
      codepoint
    )
    handle_cmd(cmd, segment)
  end
end

---@param query string
---@param segment Segment
local function search_by_fts5_query(query, segment)
  local statement = string.format(
    [[
  WITH t AS (
    SELECT cps, name, tts, rank FROM codepoint_sequence_trigram
    WHERE codepoint_sequence_trigram MATCH '%s'
    UNION
    SELECT cps, name, tts, rank FROM codepoint_sequence_porter
    WHERE codepoint_sequence_porter MATCH '%s'
  )
  SELECT cps, name, tts
  FROM t
  ORDER BY rank ASC
  LIMIT 90
  ]],
    query,
    query
  )
  local cmd =
    string.format([[~/.nix-profile/bin/sqlite3 -json ~/.nix-profile/share/unicode/unicode.sqlite3 "%s"]], statement)
  handle_cmd(cmd, segment)
end

---@param input string
---@param segment Segment
function unicode_translator(input, segment)
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

  if base ~= nil then
    local str = string.sub(input, 3)
    local codepoint = tonumber(str, base)
    if codepoint ~= nil then
      search_by_codepoint(codepoint, segment)
    end
  else
    local str = string.sub(input, 2)
    local query = prepare_fts5_query(str)
    search_by_fts5_query(query, segment)
  end
end

---@param input string
---@param segment Segment
function numeral_translator(input, segment)
  if not segment:has_tag("numeral") then
    return
  end

  -- Strip the prefix D.
  input = string.sub(input, 2)
  input = numeral.sanitize_input(input)
  if input == "" then
    return
  end

  for _, result in ipairs(numeral.format_numerals(input)) do
    yield(Candidate("numeral", segment.start, segment._end, result.candidate, result.comment))
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
    if candidate.type == "prediction" then
      candidate.preedit = "_"
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
    if candidate.type == "unicode" then
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
