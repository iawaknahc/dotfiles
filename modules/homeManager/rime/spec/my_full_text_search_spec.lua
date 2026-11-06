local FTSIndex = require("my_full_text_search")
local assert = require("luassert")

local index = FTSIndex.new("spec/my_full_text_search_documents.tsv")

-- Returns the titles of the matched documents, in result order.
local function titles(query, limit)
  local out = {}
  for _, document in ipairs(index:search(query, limit or math.huge)) do
    table.insert(out, document.title)
  end
  return out
end

describe("FTSIndex", function()
  it("returns the whole document", function()
    assert.are.same({
      { title = "1", content = "The cats run" },
    }, index:search("the", math.huge))
  end)

  it("matches a single token", function()
    assert.are.same({ "2", "1" }, titles("cats"))
  end)

  it("requires every token to match", function()
    assert.are.same({ "1" }, titles("cats run"))
    assert.are.same({}, titles("cats dog"))
  end)

  it("returns nothing when any token is unseen", function()
    assert.are.same({}, titles("xyzzy"))
    assert.are.same({}, titles("cats xyzzy"))
    assert.are.same({}, titles("xyzzy cats"))
  end)

  it("ignores case", function()
    assert.are.same({ "2", "1" }, titles("CATS"))
    assert.are.same({ "4" }, titles("smiling face"))
  end)

  it("ignores non alphanumeric characters", function()
    assert.are.same({ "2" }, titles("sleep,"))
    assert.are.same({ "2", "1" }, titles("(cats)"))
  end)

  it("matches different forms of a word by stemming", function()
    assert.are.same({ "1", "3" }, titles("running"))
    assert.are.same({ "2", "1" }, titles("cat"))
    assert.are.same({ "4" }, titles("smile"))
  end)

  it("returns nothing for a query without tokens", function()
    assert.are.same({}, titles(""))
    assert.are.same({}, titles("   "))
    assert.are.same({}, titles("--"))
  end)

  it("ignores punctuation-only tokens in the query", function()
    assert.are.same({ "2", "1" }, titles("cats --"))
  end)

  it("returns a document once even if a token repeats", function()
    -- Document 2 contains cats twice; document 4 contains smiling twice.
    assert.are.same({ "2", "1" }, titles("cats cats"))
    assert.are.same({ "4" }, titles("smiling"))
  end)

  describe("ranking", function()
    it("ranks a document higher when the token occurs more often", function()
      -- Document 2 contains cats twice; document 1 contains it once.
      assert.are.same({ "2", "1" }, titles("cats"))
    end)

    it("ranks a shorter document higher when the token occurs equally often", function()
      -- Documents 1 and 3 contain run once; document 1 is shorter.
      assert.are.same({ "1", "3" }, titles("run"))
    end)

    it("breaks ties by file order", function()
      assert.are.same({ "5", "6" }, titles("tied"))
    end)
  end)

  describe("limit", function()
    it("returns at most limit documents in ranked order", function()
      assert.are.same({}, titles("cats", 0))
      assert.are.same({ "2" }, titles("cats", 1))
      assert.are.same({ "2", "1" }, titles("cats", 2))
    end)

    it("returns every match when limit exceeds the matches", function()
      assert.are.same({ "2", "1" }, titles("cats", 10))
    end)
  end)
end)
