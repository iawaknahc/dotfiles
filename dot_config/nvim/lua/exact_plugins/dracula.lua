return {
  {
    "dracula/vim",
    -- rg "lazy = false" shows eagerly loaded plugins.
    lazy = false,
    name = "dracula",
    config = function()
      vim.cmd [[colorscheme dracula]]
      -- Make inlay hint less visually prominent.
      vim.cmd [[highlight DraculaInlayHint cterm=italic gui=italic ctermbg=NONE guibg=NONE]]
      -- 8-bit color terminal
      vim.cmd [[
highlight DraculaBgDark ctermbg=NONE
highlight DraculaBgDarker ctermbg=NONE
highlight DraculaBgLight ctermbg=8
highlight DraculaBgLighter ctermbg=8
highlight DraculaBoundary ctermfg=8 ctermbg=NONE
highlight DraculaComment ctermfg=8
highlight DraculaCommentBold ctermfg=8
highlight DraculaCyan ctermfg=4
highlight DraculaCyanItalic ctermfg=4
highlight DraculaDiffChange ctermfg=9
highlight DraculaDiffDelete ctermfg=1 ctermbg=NONE
highlight DraculaDiffText cterm=reverse ctermfg=9 ctermbg=NONE
highlight DraculaError ctermfg=1
highlight DraculaErrorLine ctermfg=1
highlight DraculaFg ctermfg=7
highlight DraculaFgBold ctermfg=7
highlight DraculaFgStrikethrough ctermfg=7
highlight DraculaFgUnderline ctermfg=7
highlight DraculaGreen ctermfg=2
highlight DraculaGreenBold ctermfg=2
highlight DraculaGreenItalic ctermfg=2
highlight DraculaGreenItalicUnderline ctermfg=2
highlight DraculaInfoLine ctermfg=4
highlight DraculaInlayHint ctermfg=8
highlight DraculaLink ctermfg=4
highlight DraculaOrange ctermfg=9
highlight DraculaOrangeBold ctermfg=9
highlight DraculaOrangeBoldItalic ctermfg=9
highlight DraculaOrangeInverse cterm=reverse ctermfg=9 ctermbg=NONE
highlight DraculaOrangeItalic ctermfg=9
highlight DraculaPink ctermfg=5
highlight DraculaPinkItalic ctermfg=5
highlight DraculaPurple ctermfg=6
highlight DraculaPurpleBold ctermfg=6
highlight DraculaPurpleItalic ctermfg=6
highlight DraculaRed ctermfg=1
highlight DraculaRedInverse ctermfg=7 ctermbg=1
highlight DraculaSearch ctermfg=2
highlight DraculaSelection ctermbg=0
highlight DraculaSubtle ctermfg=0
highlight DraculaTodo ctermfg=4
highlight DraculaWarnLine ctermfg=9
highlight DraculaWinSeparator ctermfg=8 ctermbg=NONE
highlight DraculaYellow ctermfg=3
highlight DraculaYellowItalic ctermfg=3

highlight Normal ctermfg=7 ctermbg=NONE
highlight StatusLine ctermbg=8
highlight StatusLineNC ctermbg=8
highlight StatusLineTerm ctermbg=8
highlight StatusLineTermNC ctermbg=8
highlight WildMenu cterm=bold,reverse ctermfg=6 ctermbg=NONE
highlight CursorLine ctermbg=0
highlight LineNr ctermfg=8
highlight SignColumn ctermfg=8
highlight MatchParen ctermfg=2
highlight Conceal ctermfg=4
      ]]

    end,
  },
}
