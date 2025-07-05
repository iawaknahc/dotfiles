require("lz.n").load({
  "mini.clue",
  enabled = true,
  event = { "DeferredUIEnter" },
  after = function()
    local miniclue = require("mini.clue")

    local function make_register_desc(register, fallback)
      return function()
        -- Use getreg({register}, 1, false) so that = is not evaluated.
        local ok, unsafe = pcall(vim.fn.getreg, register, 1, false)
        if not ok or type(unsafe) ~= "string" or unsafe == "" then
          return fallback
        end

        -- It seems that if we do not use vim.inspect on the register content,
        -- MiniClue will simply do not show anything if one of the register contains unusual characters.
        local lua_string_literal = vim.inspect(unsafe)

        if string.len(lua_string_literal) <= 20 then
          return lua_string_literal
        end

        return string.sub(lua_string_literal, 1, 20) .. "@@@"
      end
    end

    local function describe_registers(mode, prefix)
      local all_registers = {
        ["0"] = "Last yank",
        ["1"] = "Last delete",
        -- For unknown reason, if fallback is nil, it never appears in the clue list.
        ["2"] = nil,
        ["3"] = nil,
        ["4"] = nil,
        ["5"] = nil,
        ["6"] = nil,
        ["7"] = nil,
        ["8"] = nil,
        ["9"] = nil,
        ["a"] = "",
        ["b"] = "",
        ["c"] = "",
        ["d"] = "",
        ["e"] = "",
        ["f"] = "",
        ["g"] = "",
        ["h"] = "",
        ["i"] = "",
        ["j"] = "",
        ["k"] = "",
        ["l"] = "",
        ["m"] = "",
        ["n"] = "",
        ["o"] = "",
        ["p"] = "",
        ["q"] = "",
        ["r"] = "",
        ["s"] = "",
        ["t"] = "",
        ["u"] = "",
        ["v"] = "",
        ["w"] = "",
        ["x"] = "",
        ["y"] = "",
        ["z"] = "",
        ['"'] = "Unnamed",
        ["%"] = "Current buffer",
        ["#"] = "Alternate buffer",
        ["*"] = "Selection clipboard",
        ["+"] = "System clipboard",
        ["-"] = "Small delete",
        ["."] = "Last insert",
        ["/"] = "Last search",
        [":"] = "Last command",
        ["="] = "Expression",
        ["_"] = "Black hole",
      }

      local out = {}
      for register, fallback in pairs(all_registers) do
        table.insert(out, {
          mode = mode,
          keys = prefix .. register,
          desc = make_register_desc(register, fallback),
        })
      end
      return out
    end

    local function gen_clues_registers()
      return {
        -- Normal mode
        describe_registers("n", '"'),

        -- Visual mode
        describe_registers("x", '"'),

        -- Insert mode
        describe_registers("i", "<C-r>"),
        { mode = "i", keys = "<C-r><C-r>", desc = "+Insert literally" },
        describe_registers("i", "<C-r><C-r>"),
        { mode = "i", keys = "<C-r><C-o>", desc = "+Insert literally + not auto-indent" },
        describe_registers("i", "<C-r><C-o>"),
        { mode = "i", keys = "<C-r><C-p>", desc = "+Insert + fix indent" },
        describe_registers("i", "<C-r><C-p>"),

        -- Command-line mode
        describe_registers("c", "<C-r>"),
        { mode = "c", keys = "<C-r><C-r>", desc = "+Insert literally" },
        describe_registers("c", "<C-r><C-r>"),
        { mode = "c", keys = "<C-r><C-o>", desc = "+Insert literally" },
        describe_registers("c", "<C-r><C-o>"),
        { mode = "c", keys = "<C-r><C-f>", desc = "Insert <cfile>" },
        { mode = "c", keys = "<C-r><C-p>", desc = "Insert <cfile> in 'path'" },
        { mode = "c", keys = "<C-r><C-w>", desc = "Insert <cword>" },
        { mode = "c", keys = "<C-r><C-a>", desc = "Insert <cWORD>" },
        { mode = "c", keys = "<C-r><C-l>", desc = "Insert line under cursor" },
      }
    end
    _G.gen_clues_registers = gen_clues_registers

    miniclue.setup({
      window = {
        delay = 0,
        config = {
          width = "auto",
          anchor = "SE",
          row = "auto",
          col = "auto",
        },
      },
      triggers = {
        -- IMPORTANT: <C-x> must be written as <C-x>, not <CTRL-x>
        -- Otherwise MiniClue is confused.

        -- IMPORTANT: You cannot create a trigger with @.
        -- See https://github.com/echasnovski/mini.nvim/issues/1603

        -- <Leader>
        { mode = "n", keys = "<Leader>" },
        { mode = "x", keys = "<Leader>" },
        -- g
        { mode = "n", keys = "g" },
        { mode = "x", keys = "g" },
        -- z
        { mode = "n", keys = "z" },
        { mode = "n", keys = "Z" },
        { mode = "x", keys = "z" },
        -- ]
        { mode = "n", keys = "]" },
        { mode = "x", keys = "]" },
        -- [
        { mode = "n", keys = "[" },
        { mode = "x", keys = "[" },
        -- <Space>
        { mode = "n", keys = "<Space>" },

        -- CTRL-X is a native submode of Insert mode.
        { mode = "i", keys = "<C-x>" },

        -- CTRL-\ is a native submode of citv
        { mode = "c", keys = [[<C-\>]] },
        { mode = "i", keys = [[<C-\>]] },
        { mode = "t", keys = [[<C-\>]] },
        { mode = "v", keys = [[<C-\>]] },

        -- Marks
        { mode = "n", keys = "'" },
        { mode = "n", keys = "`" },
        { mode = "x", keys = "'" },
        { mode = "x", keys = "`" },

        -- Registers
        { mode = "n", keys = '"' },
        { mode = "x", keys = '"' },
        { mode = "i", keys = "<C-r>" },
        { mode = "c", keys = "<C-r>" },

        -- Window commands
        { mode = "n", keys = "<C-w>" },
      },
      clues = {
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.z(),
        { mode = "n", keys = "ZZ", desc = "Save and close window, :exit" },
        { mode = "n", keys = "ZQ", desc = "Quit without saving, :quit!" },

        miniclue.gen_clues.marks(),
        gen_clues_registers(),
        miniclue.gen_clues.windows(),

        -- CTRL-\
        { mode = "c", keys = [[<C-\><C-n>]], desc = "Back to normal mode" },
        { mode = "c", keys = [[<C-\><C-g>]], desc = "Back to normal mode" },
        { mode = "c", keys = [[<C-\>e]], desc = [[:h c_CTRL-\_e]] },
        { mode = "i", keys = [[<C-\><C-n>]], desc = "Back to normal mode" },
        { mode = "i", keys = [[<C-\><C-g>]], desc = "Back to normal mode" },
        { mode = "i", keys = [[<C-\><C-o>]], desc = "Like i_CTRL-O" },
        { mode = "t", keys = [[<C-\><C-n>]], desc = "Back to normal mode" },
        { mode = "t", keys = [[<C-\><C-o>]], desc = "Like i_CTRL-O" },
        { mode = "v", keys = [[<C-\><C-g>]], desc = "Back to normal mode" },

        { mode = "n", keys = "<Leader>t", desc = "+Table mode" },

        { mode = "n", keys = "gr", desc = "+LSP" },

        { mode = "n", keys = "<Leader>s", desc = "+Surround" },
        { mode = "x", keys = "<Leader>s", desc = "+Surround" },

        -- unicode.vim
        { mode = "n", keys = "<Leader>u", desc = "+Unicode" },
      },
    })

    miniclue.set_mapping_desc("n", "]d", "diagnostic")
    miniclue.set_mapping_desc("n", "]D", "Last diagnostic")
    miniclue.set_mapping_desc("n", "[d", "diagnostic")
    miniclue.set_mapping_desc("n", "[D", "First diagnostic")
  end,
})
