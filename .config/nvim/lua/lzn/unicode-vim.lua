require("lz.n").load({
  "unicode.vim",
  lazy = false,
  before = function()
    -- Disable the default mappings and re-create them in after()
    -- The rationale is to supply description.
    vim.g.Unicode_no_default_mappings = true
    -- Use the UnicodeData.txt installed by unicode-character-database
    vim.g.Unicode_data_directory = vim.fn.expand("~/.unicode")
    -- By default, it is true.
    -- If it is set to false, then <Plug>(UnicodeFuzzy) will be broken.
    vim.g.Unicode_use_cache = true
  end,
  after = function()
    vim.keymap.set("i", "<C-x><C-z>", "<Plug>(UnicodeComplete)", {
      desc = "Unicode: complete U+1234 / name",
    })
    vim.keymap.set("i", "<C-x><C-g>", "<Plug>(DigraphComplete)", {
      desc = "Unicode: complete digraph",
    })
    vim.keymap.set("i", "<C-x><C-b>", "<Plug>(HTMLEntityComplete)", {
      desc = "Unicode: complete HTML entity",
    })
    vim.keymap.set("i", "<C-g><C-f>", "<Plug>(UnicodeFuzzy)", {
      desc = "Unicode: fuzzy search with fzf",
    })
    vim.keymap.set("n", "<Leader>un", "<Plug>(UnicodeSwapCompleteName)", {
      desc = "Unicode: toggle complete glyph / name",
    })
    vim.keymap.set("n", "ga", "<Plug>(UnicodeGA)", {
      desc = "Unicode: enhanced ga",
    })
  end,
})
