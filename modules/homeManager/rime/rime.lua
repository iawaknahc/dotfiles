local json = require("json")

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
