local json = require("json")

---@param str string
---@param prefix string
---@return boolean
local function has_prefix(str, prefix)
  return string.sub(str, 1, #prefix) == prefix
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
    if codepoint ~= nil and codepoint >= 0 and codepoint <= 0x10FFFF then
      local codepoint_str = utf8.char(codepoint)
      local cmd = string.format(
        [[~/.nix-profile/bin/sqlite3 -json ~/.nix-profile/share/unicode/unicode.sqlite3 "select * from codepoint_sequence where cps = '%04X' limit 1;"]],
        codepoint
      )
      local handle = io.popen(cmd, "r")
      local stdout = handle:read("*a")
      ---@type {name: string}[]
      local rows = json.decode(stdout)
      handle:close()

      if #rows > 0 then
        local row = rows[1]
        local name = row["name"]
        if type(name) == "string" and name ~= "" then
          local candidate = Candidate("unicode", segment.start, segment._end, codepoint_str, name)
          yield(candidate)
        end
      end
    end
  end
end
