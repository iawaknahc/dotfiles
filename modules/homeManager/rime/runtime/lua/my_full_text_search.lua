local porter = require("my_porter")

---@class FTSDocument
---@field title string
---@field content string

---@class FTSIndex
---@field private _document_id integer
---@field private _postings_list { [string]: integer[] }
---@field private _frequency_list { [string]: integer[] }
---@field private _documents FTSDocument[]
---@field private _document_length_in_number_of_tokens integer[]
---@field private _total_number_of_tokens_across_all_documents integer
---@field private _porter_cache table<string, string>|nil
local FTSIndex = {}

---@return FTSIndex
function FTSIndex.new()
  local instance = setmetatable({
    _document_id = 1,
    _postings_list = {},
    _frequency_list = {},
    _documents = {},
    _document_length_in_number_of_tokens = {},
    _total_number_of_tokens_across_all_documents = 0,
    _porter_cache = {},
  }, { __index = FTSIndex })
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

---@param postings integer[]
---@param document_id integer
---@return integer|nil
local function binary_search(postings, document_id)
  local low = 1
  local high = #postings

  while low <= high do
    local mid = math.floor((low + high) / 2)
    local needle = postings[mid]
    if document_id < needle then
      high = mid - 1
    elseif document_id > needle then
      low = mid + 1
    else
      return mid
    end
  end

  return nil
end

---@param document FTSDocument
---@return integer
function FTSIndex:_assign_id_to_document(document)
  local document_id = self._document_id
  self._document_id = self._document_id + 1
  self._documents[document_id] = document
  return document_id
end

---@param token string
---@param document_id integer
function FTSIndex:_add_document_id_to_token(token, document_id)
  local postings = self._postings_list[token]
  local frequency = self._frequency_list[token]
  if postings == nil then
    self._postings_list[token] = {}
    self._frequency_list[token] = {}
    postings = self._postings_list[token]
    frequency = self._frequency_list[token]
  end

  local indexed_already = postings[#postings] == document_id
  if not indexed_already then
    table.insert(postings, document_id)
    table.insert(frequency, 1)
  else
    frequency[#frequency] = frequency[#frequency] + 1
  end
end

function FTSIndex:finish_indexing()
  self._porter_cache = nil
end

---@param document FTSDocument
function FTSIndex:add_document(document)
  if self._porter_cache == nil then
    error("The index is frozen")
  end

  local length_in_number_of_tokens = 0
  local document_id = self:_assign_id_to_document(document)
  for token in tokenize(document.content, self._porter_cache) do
    self:_add_document_id_to_token(token, document_id)
    length_in_number_of_tokens = length_in_number_of_tokens + 1
  end
  self._document_length_in_number_of_tokens[document_id] = length_in_number_of_tokens
  self._total_number_of_tokens_across_all_documents = self._total_number_of_tokens_across_all_documents
    + length_in_number_of_tokens
end

---@return number|nil
function FTSIndex:_get_average_number_of_tokens_across_all_documents()
  if #self._documents ~= 0 then
    return self._total_number_of_tokens_across_all_documents / #self._documents
  end
  return nil
end

---@param tokens string[]
---@param matched_postings integer[]
---@return { document_id: integer, bm25_score: number }[]
function FTSIndex:_calculate_bm25_scores(tokens, matched_postings)
  local N = #self._documents
  ---@type number[]
  local idfs = {}
  for idx, token in ipairs(tokens) do
    local postings = self._postings_list[token]
    local n = #postings
    local idf = math.log(((N - n + 0.5) / (n + 0.5)) + 1)
    idfs[idx] = idf
  end

  ---@type { document_id: integer, bm25_score: number }[]
  local document_ids_with_bm25_score = {}
  local k1 = 1.2
  local b = 0.75
  local avgdl = self:_get_average_number_of_tokens_across_all_documents()
  for _, document_id in ipairs(matched_postings) do
    ---@type number
    local bm25_score = 0
    local D = self._document_length_in_number_of_tokens[document_id] --[[@as integer]]
    if avgdl ~= nil then
      for idx_token, token in ipairs(tokens) do
        local postings = self._postings_list[token]
        local frequency = self._frequency_list[token]
        local index = binary_search(postings, document_id)
        if index ~= nil then
          local idf = idfs[idx_token] --[[@as number]]
          local f = frequency[index] --[[@as integer]]
          bm25_score = bm25_score + idf * ((f * (k1 + 1)) / (f + k1 * (1 - b + b * (D / avgdl))))
        end
      end
    end

    table.insert(document_ids_with_bm25_score, {
      document_id = document_id,
      bm25_score = bm25_score,
    })
  end

  table.sort(document_ids_with_bm25_score, function(element_a, element_b)
    if element_a.bm25_score ~= element_b.bm25_score then
      return element_a.bm25_score > element_b.bm25_score
    end
    return element_a.document_id < element_b.document_id
  end)

  return document_ids_with_bm25_score
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

  local document_ids_with_bm25_score = self:_calculate_bm25_scores(tokens, matched_postings)
  ---@type FTSDocument[]
  local documents = {}
  for i = 1, math.min(#document_ids_with_bm25_score, limit) do
    local with_score = document_ids_with_bm25_score[i]
    if with_score ~= nil then
      local document = self._documents[with_score.document_id]
      table.insert(documents, document)
    end
  end

  return documents
end

return FTSIndex
