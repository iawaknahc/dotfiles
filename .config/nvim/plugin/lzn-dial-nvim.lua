local once = require("once")

local setup = once(function()
  local augend = require("dial.augend")
  local augend_common = require("dial.augend.common")

  local c_bool_operators = augend.constant.new({
    elements = {
      "&&",
      "||",
    },
    word = true,
    cyclic = true,
  })

  local python_bool_operators = augend.constant.new({
    elements = {
      "and",
      "or",
    },
    word = true,
    cyclic = true,
  })

  local python_bool = augend.constant.new({
    elements = {
      "False",
      "True",
    },
    word = true,
    cyclic = true,
  })

  local en_ordinals = augend.constant.new({
    elements = {
      "first",
      "second",
      "third",
      "fourth",
      "fifth",
      "sixth",
      "seventh",
      "eighth",
      "ninth",
      "tenth",
    },
    -- Match "firstDate"
    word = false,
    cyclic = true,
    preserve_case = true,
  })

  local en_weekdays_short = augend.constant.new({
    elements = {
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    },
    word = true,
    cyclic = true,
  })

  local en_weekdays_long = augend.constant.new({
    elements = {
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    },
    word = true,
    cyclic = true,
  })

  local en_months_long = augend.constant.new({
    elements = {
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    },
    word = true,
    cyclic = true,
  })

  local markdown_checkbox = augend.constant.new({
    elements = {
      "[ ]",
      "[x]",
    },
    word = false,
    cyclic = true,
  })

  local regex_rfc3339 = [[%(["']\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}%(\.\d+)?%(Z|[-+]\d{2}:\d{2})?["'])]]
  local regex_unix = [[%(\d+)]]

  local timestamps = augend.user.new({
    find = augend_common.find_pattern_regex(table.concat({
      [[\v]], -- Very magic
      regex_rfc3339,
      [[|]], -- Or
      regex_unix,
    })),
    ---@param text string
    ---@param _addend integer
    ---@param cursor? integer
    ---@return { text?: string, cursor?: integer }
    add = function(text, _addend, cursor)
      local python_datetime = require("python_datetime")

      if vim.regex([[\v]] .. regex_rfc3339):match_str(text) then
        -- Remove the quotes.
        text = string.sub(text, 2, -2)

        local unix = python_datetime.rfc3339_to_unix(text)
        if unix ~= nil then
          text = tostring(unix)
          cursor = #text
          return { text = text, cursor = cursor }
        end
      end

      if vim.regex([[\v]] .. regex_unix):match_str(text) then
        local unix = tonumber(text)
        if unix ~= nil then
          unix = math.floor(unix)
          local rfc3339 = python_datetime.unix_to_rfc3339(unix)
          text = [["]] .. tostring(rfc3339) .. [["]]
          cursor = #text
          return { text = text, cursor = cursor }
        end
      end

      return {}
    end,
  })

  local regex_iso_3166_1_alpha_2 = [[%(<[A-Z]{2}>)]]
  -- For unknown reason, if {2} is used, the regex matches nothing, so + is used instead.
  local regex_unicode_tag_block = [[%(<[\U1F1E6-\U1F1FF]+>)]]

  local unicode_iso_3166_1_alpha_2 = augend.user.new({
    find = augend_common.find_pattern_regex(table.concat({
      [[\v]], -- Very magic
      regex_iso_3166_1_alpha_2,
      [[|]], -- Or
      regex_unicode_tag_block,
    })),
    ---@param text string
    ---@param _addend integer
    ---@param cursor? integer
    ---@return { text?: string, cursor?: integer }
    add = function(text, _addend, cursor)
      local utf8 = require("lua-utf8")
      if vim.regex([[\v]] .. regex_iso_3166_1_alpha_2):match_str(text) then
        local codepoints = {}
        for _, codepoint in utf8.codes(text) do
          -- 65 is ASCII A
          -- 0x1F1E6 is U+1F1E6
          table.insert(codepoints, codepoint - 65 + 0x1F1E6)
        end
        text = utf8.char(unpack(codepoints))
        cursor = #text
        return { text = text, cursor = cursor }
      end
      if vim.regex([[\v]] .. regex_unicode_tag_block):match_str(text) then
        local codepoints = {}
        for _, codepoint in utf8.codes(text) do
          -- 65 is ASCII A
          -- 0x1F1E6 is U+1F1E6
          table.insert(codepoints, codepoint - 0x1F1E6 + 65)
        end
        text = utf8.char(unpack(codepoints))
        cursor = #text
        return { text = text, cursor = cursor }
      end
      return {}
    end,
  })

  require("dial.config").augends:register_group({
    default = {
      augend.integer.alias.decimal, -- 0, 1, 2, …
      augend.integer.alias.decimal_int, -- -1, 0, 1, 2, …
      augend.integer.alias.hex, -- 0x0, …
      augend.integer.alias.octal, -- 0o0, …
      augend.integer.alias.binary, -- 0b0, …

      augend.constant.alias.alpha, -- a, b, c, …
      augend.constant.alias.Alpha, -- A, B, C, …

      augend.semver.alias.semver, -- 0.0.0, 0.0.1, …

      augend.date.alias["%Y/%m/%d"], -- 2006/01/02
      augend.date.alias["%Y-%m-%d"], -- 2006-01-02
      augend.date.alias["%H:%M:%S"], -- 15:04:05
      augend.date.alias["%H:%M"], -- 15:04

      c_bool_operators,
      python_bool_operators,

      augend.constant.alias.bool, -- true, false
      python_bool,

      en_ordinals,
      en_weekdays_long,
      en_weekdays_short,
      en_months_long,
      -- There is no en_months_short because the month May has its long form and short form identical.
      -- It is ambiguous when incrementing May.

      markdown_checkbox,
    },
    ctrl_shift = {
      timestamps,
      unicode_iso_3166_1_alpha_2,
    },
  })
  return nil
end)

vim.keymap.set("n", "<C-a>", function()
  setup()
  require("dial.map").manipulate("increment", "normal")
end)
vim.keymap.set("n", "<C-x>", function()
  setup()
  require("dial.map").manipulate("decrement", "normal")
end)
vim.keymap.set("n", "g<C-a>", function()
  setup()
  require("dial.map").manipulate("increment", "gnormal")
end)
vim.keymap.set("n", "g<C-x>", function()
  setup()
  require("dial.map").manipulate("decrement", "gnormal")
end)
vim.keymap.set("x", "<C-a>", function()
  setup()
  require("dial.map").manipulate("increment", "visual")
end)
vim.keymap.set("x", "<C-x>", function()
  setup()
  require("dial.map").manipulate("decrement", "visual")
end)
vim.keymap.set("x", "g<C-a>", function()
  setup()
  require("dial.map").manipulate("increment", "gvisual")
end)
vim.keymap.set("x", "g<C-x>", function()
  setup()
  require("dial.map").manipulate("decrement", "gvisual")
end)

vim.keymap.set("n", "<C-S-a>", function()
  setup()
  require("dial.map").manipulate("increment", "normal", "ctrl_shift")
end)
vim.keymap.set("n", "<C-S-x>", function()
  setup()
  require("dial.map").manipulate("decrement", "normal", "ctrl_shift")
end)
vim.keymap.set("n", "g<C-S-a>", function()
  setup()
  require("dial.map").manipulate("increment", "gnormal", "ctrl_shift")
end)
vim.keymap.set("n", "g<C-S-x>", function()
  setup()
  require("dial.map").manipulate("decrement", "gnormal", "ctrl_shift")
end)
vim.keymap.set("x", "<C-S-a>", function()
  setup()
  require("dial.map").manipulate("increment", "visual", "ctrl_shift")
end)
vim.keymap.set("x", "<C-S-x>", function()
  setup()
  require("dial.map").manipulate("decrement", "visual", "ctrl_shift")
end)
vim.keymap.set("x", "g<C-S-a>", function()
  setup()
  require("dial.map").manipulate("increment", "gvisual", "ctrl_shift")
end)
vim.keymap.set("x", "g<C-S-x>", function()
  setup()
  require("dial.map").manipulate("decrement", "gvisual", "ctrl_shift")
end)
