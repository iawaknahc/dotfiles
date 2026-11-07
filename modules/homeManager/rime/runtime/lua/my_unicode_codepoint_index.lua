---@class UnicodeCodepointIndex
---@field private _index table<integer, FTSDocument|nil>
local UnicodeCodepointIndex = {}

function UnicodeCodepointIndex.new()
  local instance = setmetatable({
    _index = {},
  }, { __index = UnicodeCodepointIndex })
  return instance
end

---@param document FTSDocument
function UnicodeCodepointIndex:add_document(document)
  ---@type integer[]
  local codepoints = {}
  for codepoint_str in string.gmatch(document.title, "[^ ]+") do
    local codepoint = tonumber(codepoint_str, 16)
    if codepoint ~= nil then
      table.insert(codepoints, codepoint)
    end
  end

  -- This index is only for single codepoint, not for codepoint sequences.
  if #codepoints ~= 1 then
    return
  end

  local codepoint = codepoints[1]
  self._index[codepoint] = document
end

---@param codepoint integer
---@return FTSDocument[]
function UnicodeCodepointIndex:search(codepoint)
  local document = self._index[codepoint]
  if document == nil then
    return {}
  end
  return { document }
end

return UnicodeCodepointIndex
