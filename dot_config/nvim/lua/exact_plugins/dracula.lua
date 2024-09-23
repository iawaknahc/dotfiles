-- As of 2024-06-16, the following highlight groups are not linked to Dracula.
--
-- @lsp.type.modifier links to non-existent @type.qualifier
-- CmpItemAbbrDeprecatedDefault xxx guifg=NvimLightGrey4
-- CmpItemKindDefault xxx guifg=NvimLightCyan
-- FloatShadow    xxx ctermbg=0 guibg=NvimDarkGrey4 blend=80
-- FloatShadowThrough xxx ctermbg=0 guibg=NvimDarkGrey4 blend=100
-- ModeMsg        xxx ctermfg=10 guifg=NvimLightGreen
-- NormalFloat    xxx guibg=NvimDarkGrey1
-- QuickFixLine   xxx ctermfg=14 guifg=NvimLightCyan
-- RedrawDebugClear xxx ctermfg=0 ctermbg=11 guibg=NvimDarkYellow
-- RedrawDebugComposed xxx ctermfg=0 ctermbg=10 guibg=NvimDarkGreen
-- RedrawDebugRecompose xxx ctermfg=0 ctermbg=9 guibg=NvimDarkRed
-- WinBar         xxx cterm=bold gui=bold guifg=NvimLightGrey4 guibg=NvimDarkGrey1
-- WinBarNC       xxx cterm=bold guifg=NvimLightGrey4 guibg=NvimDarkGrey1

return {
  {
    "dracula/vim",
    enabled = true,
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

highlight Conceal ctermfg=4
highlight CursorLine ctermbg=0
highlight LineNr ctermfg=8
highlight MatchParen ctermfg=2
highlight Normal ctermfg=7 ctermbg=NONE
highlight PmenuMatch ctermfg=4 ctermbg=NONE
highlight PmenuMatchSel ctermfg=4 ctermbg=8
highlight SignColumn ctermfg=8
highlight StatusLine ctermbg=8
highlight StatusLineNC ctermbg=8
highlight StatusLineTerm ctermbg=8
highlight StatusLineTermNC ctermbg=8
highlight WildMenu cterm=bold,reverse ctermfg=6 ctermbg=NONE
      ]]

      -- Missing groups
      vim.cmd [[
highlight Added guifg=#50fa7b
highlight Removed guifg=#ff5555
highlight Changed guifg=#ffb86c
highlight DiagnosticDeprecated guisp=#ff5555
highlight DiagnosticOk guifg=#50fa7b
highlight DiagnosticUnderlineOk guisp=#50fa7b
      ]]

    end,
  },
}
