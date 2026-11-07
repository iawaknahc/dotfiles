local UnicodeCodepointIndex = require("my_unicode_codepoint_index")
local assert = require("luassert")

---@type FTSDocument[]
local documents = {
  { title = "0041", content = "LATIN CAPITAL LETTER A" },
  { title = "1F415", content = "DOG dog" },
  { title = "1F415 FE0F", content = "DOG emoji style dog emoji style" },
  { title = "1F415 200D 1F9BA", content = "service dog service dog" },
}

local index = UnicodeCodepointIndex.new()
for _, document in ipairs(documents) do
  index:add_document(document)
end

-- Returns the titles of the matched documents, in result order.
local function titles(codepoint)
  local out = {}
  for _, document in ipairs(index:search(codepoint)) do
    table.insert(out, document.title)
  end
  return out
end

describe("UnicodeCodepointIndex", function()
  it("returns the whole document", function()
    assert.are.same({
      { title = "0041", content = "LATIN CAPITAL LETTER A" },
    }, index:search(0x41))
  end)

  it("finds a document by its codepoint", function()
    assert.are.same({ "0041" }, titles(0x41))
  end)

  it("returns nothing for a codepoint not in any document", function()
    assert.are.same({}, titles(0x42))
  end)

  it("does not match the position of a codepoint within a sequence", function()
    assert.are.same({}, titles(1))
    assert.are.same({}, titles(2))
    assert.are.same({}, titles(3))
  end)

  it("ignores codepoint sequences", function()
    assert.are.same({ "1F415" }, titles(0x1F415))
    assert.are.same({}, titles(0xFE0F))
    assert.are.same({}, titles(0x200D))
    assert.are.same({}, titles(0x1F9BA))
  end)

  it("keeps only the last document added for the same codepoint", function()
    local duplicated = UnicodeCodepointIndex.new()
    duplicated:add_document({ title = "0041", content = "first" })
    duplicated:add_document({ title = "0041", content = "second" })
    assert.are.same({
      { title = "0041", content = "second" },
    }, duplicated:search(0x41))
  end)
end)
