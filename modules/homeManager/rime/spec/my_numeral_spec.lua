local numeral = require("my_numeral")
local assert = require("luassert")

-- Returns the candidates in the order 香港小寫, 香港大寫, 香港支票.
local function candidates(input)
  local out = {}
  for _, result in ipairs(numeral.format_numerals(input)) do
    table.insert(out, result.candidate)
  end
  return out
end

describe("format_numerals", function()
  it("returns one result per configuration", function()
    assert.are.same({
      { candidate = "一", comment = "香港小寫" },
      { candidate = "壹", comment = "香港大寫" },
      { candidate = "壹", comment = "香港支票" },
    }, numeral.format_numerals("1"))
  end)

  describe("single group", function()
    it("formats zero", function()
      assert.are.same({ "零", "零", "零" }, candidates("0"))
    end)

    it("formats a single digit", function()
      assert.are.same({ "七", "柒", "柒" }, candidates("7"))
    end)

    it("skips the numeral for ten except on checks", function()
      assert.are.same({ "十", "拾", "壹拾" }, candidates("10"))
      assert.are.same({ "十一", "拾壹", "壹拾壹" }, candidates("11"))
    end)

    it("keeps the numeral for multiples of ten other than ten", function()
      assert.are.same({ "二十", "貳拾", "貳拾" }, candidates("20"))
    end)

    it("keeps the numeral for ten when it is not the leading digit", function()
      assert.are.same({ "一百一十", "壹佰壹拾", "壹佰壹拾" }, candidates("110"))
    end)

    it("formats hundreds and thousands", function()
      assert.are.same({ "一百", "壹佰", "壹佰" }, candidates("100"))
      assert.are.same({ "九千九百九十九", "玖仟玖佰玖拾玖", "玖仟玖佰玖拾玖" }, candidates("9999"))
    end)

    it("inserts a zero for inner zeros", function()
      assert.are.same({ "一百零一", "壹佰零壹", "壹佰零壹" }, candidates("101"))
      assert.are.same({ "一千零一十", "壹仟零壹拾", "壹仟零壹拾" }, candidates("1010"))
    end)

    it("collapses consecutive inner zeros into one zero", function()
      assert.are.same({ "一千零一", "壹仟零壹", "壹仟零壹" }, candidates("1001"))
    end)
  end)

  describe("multiple groups", function()
    it("formats 萬", function()
      assert.are.same({ "一萬", "壹萬", "壹萬" }, candidates("10000"))
    end)

    it("applies the ten rule to the leading group", function()
      assert.are.same({ "十萬", "拾萬", "壹拾萬" }, candidates("100000"))
      assert.are.same({ "十一萬", "拾壹萬", "壹拾壹萬" }, candidates("110000"))
    end)

    it("inserts a zero when a lower group has leading zeros", function()
      assert.are.same({ "一萬零一", "壹萬零壹", "壹萬零壹" }, candidates("10001"))
      assert.are.same({ "一萬零一百", "壹萬零壹佰", "壹萬零壹佰" }, candidates("10100"))
    end)

    it("inserts a single zero across an empty group", function()
      assert.are.same({ "一億零一", "壹億零壹", "壹億零壹" }, candidates("100000001"))
    end)

    it("omits trailing empty groups", function()
      assert.are.same({ "一億", "壹億", "壹億" }, candidates("100000000"))
    end)

    it("formats the largest group", function()
      assert.are.same({ "一萬億", "壹萬億", "壹萬億" }, candidates("1000000000000"))
      assert.are.same(
        { "九千九百九十九萬億", "玖仟玖佰玖拾玖萬億", "玖仟玖佰玖拾玖萬億" },
        candidates("9999000000000000")
      )
    end)

    it("reports numbers that are too large", function()
      assert.are.same({
        { candidate = "數值過大", comment = "香港小寫" },
        { candidate = "數值過大", comment = "香港大寫" },
        { candidate = "數值過大", comment = "香港支票" },
      }, numeral.format_numerals("10000000000000000"))
    end)
  end)
end)

describe("sanitize_input", function()
  it("keeps plain digits", function()
    assert.are.equal("123", numeral.sanitize_input("123"))
  end)

  it("strips leading zeros", function()
    assert.are.equal("7", numeral.sanitize_input("007"))
  end)

  it("keeps a single zero", function()
    assert.are.equal("0", numeral.sanitize_input("0"))
    assert.are.equal("0", numeral.sanitize_input("000"))
  end)

  it("drops the decimal part", function()
    assert.are.equal("12", numeral.sanitize_input("12.5"))
    assert.are.equal("12", numeral.sanitize_input("12."))
  end)

  it("strips non-digits", function()
    assert.are.equal("1000", numeral.sanitize_input("1,000"))
  end)

  it("returns an empty string when there are no digits", function()
    assert.are.equal("", numeral.sanitize_input(""))
    assert.are.equal("", numeral.sanitize_input("."))
    assert.are.equal("", numeral.sanitize_input(".5"))
  end)
end)
