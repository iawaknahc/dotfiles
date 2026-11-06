local porter = require("my_porter")
local assert = require("luassert")

local function read_lines(path)
  local lines = {}
  for line in io.lines(path) do
    table.insert(lines, line)
  end
  return lines
end

describe("porter", function()
  it("matches the official sample output", function()
    local words = read_lines("spec/my_porter_voc.txt")
    local stems = read_lines("spec/my_porter_output.txt")
    assert.are.equal(#words, #stems)

    local mismatches = {}
    for i, word in ipairs(words) do
      local actual = porter(word)
      if actual ~= stems[i] then
        table.insert(mismatches, string.format("%s: expected %s, got %s", word, stems[i], actual))
      end
    end
    assert.are.same({}, mismatches)
  end)

  -- The C implementation departs from the published algorithm in three points.
  -- See https://tartarus.org/martin/PorterStemmer/
  describe("follows the C implementation rather than the paper", function()
    it("replaces bli with ble instead of abli with able in step 2", function()
      -- The paper leaves possibly as possibli.
      assert.are.equal("possibl", porter("possibly"))
      assert.are.equal("possibl", porter("possible"))
    end)

    it("replaces logi with log in step 2", function()
      -- The paper leaves archaeology as archaeologi.
      assert.are.equal("archaeolog", porter("archaeology"))
      assert.are.equal("archaeolog", porter("archaeological"))
    end)

    it("leaves strings of length 1 or 2 alone", function()
      -- The paper stems `as` to `a` and `is` to `i`.
      assert.are.equal("as", porter("as"))
      assert.are.equal("is", porter("is"))
    end)
  end)
end)
