require("lz.n").load({
  "dial.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    local augend = require("dial.augend")
    local augendcommon = require("dial.augend.common")

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
      find = augendcommon.find_pattern_regex(table.concat({
        [[\v]], -- Very magic
        regex_rfc3339,
        [[|]], -- Or
        regex_unix,
      })),
      ---@param text string
      ---@param addend integer
      ---@param cursor? integer
      ---@return { text?: string, cursor?: integer }
      add = function(text, addend, cursor)
        if vim.regex([[\v]] .. regex_rfc3339):match_str(text) then
          -- Remove the quotes.
          text = string.sub(text, 2, -2)

          local unix = _G.rfc3339_to_unix(text)
          if unix ~= nil then
            text = tostring(unix)
            cursor = #text
            return { text = text, cursor = cursor }
          end
        end

        if vim.regex([[\v]] .. regex_unix):match_str(text) then
          local unix = tonumber(text)
          if unix ~= nil then
            local rfc3339 = _G.unix_to_rfc3339(unix)
            text = [["]] .. tostring(rfc3339) .. [["]]
            cursor = #text
            return { text = text, cursor = cursor }
          end
        end

        return {}
      end,
    })

    require("dial.config").augends:register_group({
      default = {
        augend.integer.alias.decimal, -- 0, 1, 2, ...
        augend.integer.alias.decimal_int, -- -1, 0, 1, 2, ...
        augend.integer.alias.hex, -- 0x0, ...
        augend.integer.alias.octal, -- 0o0, ...
        augend.integer.alias.binary, -- 0b0, ...

        augend.constant.alias.alpha, -- a, b, c, ...
        augend.constant.alias.Alpha, -- A, B, C, ...

        augend.semver.alias.semver, -- 0.0.0, 0.0.1, ...

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
      ctrlshift = {
        timestamps,
      },
    })

    vim.cmd([[
      nmap  <C-a>  <Plug>(dial-increment)
      nmap  <C-x>  <Plug>(dial-decrement)
      nmap g<C-a> g<Plug>(dial-increment)
      nmap g<C-x> g<Plug>(dial-decrement)
      vmap  <C-a>  <Plug>(dial-increment)
      vmap  <C-x>  <Plug>(dial-decrement)
      vmap g<C-a> g<Plug>(dial-increment)
      vmap g<C-x> g<Plug>(dial-decrement)

      nmap  <C-S-a> "=ctrlshift<CR><Plug>(dial-increment)
      nmap  <C-S-x> "=ctrlshift<CR><Plug>(dial-decrement)
      nmap g<C-S-a> "=ctrlshift<CR>g<Plug>(dial-increment)
      nmap g<C-S-x> "=ctrlshift<CR>g<Plug>(dial-decrement)
      vmap  <C-S-a> "=ctrlshift<CR><Plug>(dial-increment)
      vmap  <C-S-x> "=ctrlshift<CR><Plug>(dial-decrement)
      vmap g<C-S-a> "=ctrlshift<CR>g<Plug>(dial-increment)
      vmap g<C-S-x> "=ctrlshift<CR>g<Plug>(dial-decrement)
    ]])
  end,
})
