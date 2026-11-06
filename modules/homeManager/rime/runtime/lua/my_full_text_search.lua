local porter = require("my_porter")

---@class FTSDocument
---@field title string
---@field content string

---@class FTSIndex
---@field path string
---@field private _document_id integer
---@field private _postings_list { [string]: integer[] }
---@field private _documents FTSDocument[]
local FTSIndex = {}

---@param path string
---@return FTSIndex
function FTSIndex.new(path)
  local instance = setmetatable({
    path = path,
    _document_id = 1,
    _postings_list = {},
    _documents = {},
  }, { __index = FTSIndex })
  instance:_prepare()
  return instance
end

---@param str string
---@param porter_cache table<string, string>|nil
---@return fun(): string|nil
local function tokenize(str, porter_cache)
  local iter = string.gmatch(str, "%g+")
  return function()
    for word in iter do
      local token = word
      -- Downcase the token.
      token = string.lower(token)
      -- Remove non alphanumeric characters.
      token = string.gsub(token, "[^%w]+", "")
      if token ~= "" then
        -- Stem it
        if porter_cache ~= nil then
          local cached_result = porter_cache[token]
          if cached_result == nil then
            cached_result = porter(token)
            porter_cache[token] = cached_result
          end
          token = cached_result
        else
          token = porter(token)
        end

        return token
      end
    end
  end
end

---@param a integer[]
---@param b integer[]
---@return integer[]
local function intersection(a, b)
  local i = 1
  local j = 1
  local out = {}
  while i <= #a and j <= #b do
    local document_id_a = a[i]
    local document_id_b = b[j]
    if document_id_a == document_id_b then
      table.insert(out, document_id_a)
      i = i + 1
      j = j + 1
    elseif document_id_a < document_id_b then
      i = i + 1
    elseif document_id_a > document_id_b then
      j = j + 1
    end
  end
  return out
end

---@param document FTSDocument
---@return integer
function FTSIndex:_add_document(document)
  local document_id = self._document_id
  self._document_id = self._document_id + 1
  self._documents[document_id] = document
  return document_id
end

---@param token string
---@param document_id integer
function FTSIndex:_add_document_id_to_token(token, document_id)
  local postings = self._postings_list[token]
  if postings == nil then
    self._postings_list[token] = {}
    postings = self._postings_list[token]
  end

  local indexed_already = postings[#postings] == document_id
  if not indexed_already then
    table.insert(postings, document_id)
  end
end

function FTSIndex:_prepare()
  local porter_cache = {}
  for line in io.lines(self.path) do
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

    local document = {
      title = title,
      content = content,
    }
    local document_id = self:_add_document(document)
    for token in tokenize(content, porter_cache) do
      self:_add_document_id_to_token(token, document_id)
    end
  end
end

---@param query string
---@param limit integer
---@return FTSDocument[]
function FTSIndex:search(query, limit)
  ---@type string[]
  local tokens = {}
  for token in tokenize(query, nil) do
    table.insert(tokens, token)
  end

  ---@type integer[]|nil
  local matched_postings = nil
  for _, token in ipairs(tokens) do
    local postings = self._postings_list[token]
    -- If there is no postings, then the token is unseen during indexing.
    if postings == nil then
      return {}
    end

    if matched_postings == nil then
      matched_postings = postings
    else
      matched_postings = intersection(matched_postings, postings)
    end
  end

  if matched_postings == nil then
    return {}
  end

  ---@type FTSDocument[]
  local documents = {}
  for i = 1, math.min(#matched_postings, limit) do
    local document_id = matched_postings[i]
    if document_id ~= nil then
      local document = self._documents[document_id]
      table.insert(documents, document)
    end
  end

  return documents
end

return FTSIndex
