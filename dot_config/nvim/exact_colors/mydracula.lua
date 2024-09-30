-- palette
local fg = "#f8f8f2"

local bg_lighter = "#424450"
local bg_light = "#343746"
local bg = "#282a36"
local bg_dark = "#21222c"
local bg_darker = "#191a21"

local comment = "#6272a4"
local selection = "#44475a"
local subtle = "#424450"

local cyan = "#8be9fd"
local green = "#50fa7b"
local orange = "#ffb86c"
local pink = "#ff79c6"
local purple = "#bd93f9"
local red = "#ff5555"
local yellow = "#f1fa8c"


-- helper functions
local function hi(opts)
  local name = opts[1]
  opts[1] = nil
  vim.api.nvim_set_hl(0, name, opts)
end


-- This is how a colorscheme should start
vim.cmd[[
hi! clear
]]
vim.o.background = 'dark'


-- bg
hi { "DraculaBgLighter", bg = bg_lighter }
hi { "DraculaBgLight", bg = bg_light }
hi { "DraculaBg", bg = bg }
hi { "DraculaBgDark", bg = bg_dark }
hi { "DraculaBgDarker", bg = bg_darker }

-- fg
hi { "DraculaFg", fg = fg }
hi { "DraculaFgUnderline", underline = true }
hi { "DraculaFgBold", bold = true }
hi { "DraculaFgStrikethrough", strikethrough = true }

-- comment
hi { "DraculaComment", fg = comment }
hi { "DraculaCommentBold", fg = comment, bold = true }

-- selection
hi { "DraculaSelection", bg = selection }

-- subtle
hi { "DraculaSubtle", fg = subtle }

-- cyan
hi { "DraculaCyan", fg = cyan }
hi { "DraculaCyanItalic", fg = cyan, italic = true }
hi { "DraculaCyanUndercurl", fg = cyan, sp = cyan, undercurl = true }

-- green
hi { "DraculaGreen", fg = green }
hi { "DraculaGreenBold", fg = green, bold = true }
hi { "DraculaGreenItalic", fg = green, italic = true }
hi { "DraculaGreenUnderline", fg = green, underline = true }
hi { "DraculaGreenItalicUnderline", fg = green, italic = true, underline = true }
hi { "DraculaGreenUndercurl", fg = green, sp = green, undercurl = true }

-- orange
hi { "DraculaOrange", fg = orange }
hi { "DraculaOrangeBold", fg = orange, bold = true }
hi { "DraculaOrangeItalic", fg = orange, italic = true }
hi { "DraculaOrangeBoldItalic", fg = orange, bold = true, italic = true }
hi { "DraculaOrangeInverse", fg = orange, reverse = true }
hi { "DraculaOrangeUndercurl", fg = orange, sp = orange, undercurl = true }

-- pink
hi { "DraculaPink", fg = pink }
hi { "DraculaPinkItalic", fg = pink, italic = true }

-- purple
hi { "DraculaPurple", fg = purple }
hi { "DraculaPurpleBold", fg = purple, bold = true }
hi { "DraculaPurpleItalic", fg = purple, italic = true }

-- red
hi { "DraculaRed", fg = red }
hi { "DraculaRedItalic", fg = red, italic = true }
hi { "DraculaRedInverse", fg = red, reverse = true }
hi { "DraculaRedUndercurl", fg = red, sp = red, undercurl = true }

-- yellow
hi { "DraculaYellow", fg = yellow }
hi { "DraculaYellowItalic", fg = yellow, italic = true }


-- semantics
hi { "DraculaError", link = "DraculaRed" }
hi { "DraculaWarn", link = "DraculaOrange" }
hi { "DraculaInfo", link = "DraculaCyan" }
hi { "DraculaHint", link = "DraculaCyan" }
hi { "DraculaOk", link = "DraculaGreen" }

hi { "DraculaErrorVirtualText", link = "DraculaRedItalic" }
hi { "DraculaWarnVirtualText", link = "DraculaOrangeItalic" }
hi { "DraculaInfoVirtualText", link = "DraculaCyanItalic" }
hi { "DraculaHintVirtualText", link = "DraculaCyanItalic" }
hi { "DraculaOkVirtualText", link = "DraculaGreenItalic" }

hi { "DraculaErrorLine", link = "DraculaRedUndercurl" }
hi { "DraculaWarnLine", link = "DraculaOrangeUndercurl" }
hi { "DraculaInfoLine", link = "DraculaCyanUndercurl" }
hi { "DraculaHintLine", link = "DraculaCyanUndercurl" }
hi { "DraculaOkLine", link = "DraculaGreenUndercurl" }

hi { "DraculaTodo", fg = cyan, bold = true, reverse = true }
hi { "DraculaSearch", fg = green, reverse = true }
hi { "DraculaCurSearch", fg = yellow, reverse = true }
hi { "DraculaBoundary", fg = comment, bg = bg_dark }
hi { "DraculaWinSeparator", link = "DraculaBoundary" }
hi { "DraculaLink", fg = cyan, underline = true }

hi { "DraculaDiffChange", link = "DraculaOrange" }
hi { "DraculaDiffDelete", link = "DraculaRed" }
hi { "DraculaDiffText", link = "DraculaOrangeInverse" }

hi { "DraculaInlayHint", link = "SpecialComment" }

-- These originally do not appear in the source repo.
hi { "DraculaWildMenu", fg = purple, bold = true, reverse = true}
hi { "DraculaStatusLine", bg = bg_lighter, bold = true }
hi { "DraculaStatusLineNC", bg = bg_light }
hi { "DraculaCursor", reverse = true }

-- :help highlight-groups
hi { "Normal", bg = bg, fg = fg }
hi { "Directory", link = "DraculaPurpleBold" }

hi { "ColorColumn", link = "DraculaBgDark" }

hi { "NonText", link = "DraculaSubtle" }
hi { "EndOfBuffer", link = "NonText" }
hi { "Conceal", link = "DraculaCyan" }
hi { "NormalNC" }
hi { "Whitespace", link = "NonText" }
hi { "SpecialKey", link = "DraculaRed" }

hi { "CurSearch", link = "DraculaCurSearch" }
hi { "Search", link = "DraculaSearch" }
hi { "IncSearch", link = "DraculaOrangeInverse" }
hi { "Substitute", link = "Search" }

hi { "Cursor", link = "DraculaCursor" }
hi { "lCursor", link = "Cursor" }
hi { "CursorIM", link = "Cursor" }
hi { "TermCursor", link = "Cursor" }
hi { "TermCursorNC" }

hi { "Visual", link = "DraculaSelection" }
hi { "CursorLine", link = "DraculaBgLighter" }
hi { "CursorColumn", link = "CursorLine" }
hi { "VisualNOS", link = "Visual" }
hi { "SnippetTabstop", link = "Visual" }

hi { "DiffAdd", link = "DraculaGreen" }
hi { "DiffChange", link = "DraculaDiffChange" }
hi { "DiffDelete", link = "DraculaDiffDelete" }
hi { "DiffText", link = "DraculaDiffText" }

hi { "ErrorMsg", link = "DraculaRedInverse" }
hi { "WarningMsg", link = "DraculaOrangeInverse" }

hi { "SpellBad", link = "DraculaErrorLine" }
hi { "SpellRare", link = "DraculaInfoLine" }
hi { "SpellCap", link = "DraculaInfoLine" }
hi { "SpellLocal", link = "DraculaWarnLine" }

hi { "WinSeparator", link = "DraculaWinSeparator" }
hi { "Folded", link = "DraculaBoundary" }

hi { "Pmenu", link = "DraculaBgDark" }
hi { "PmenuKind", link = "Pmenu" }
hi { "PmenuExtra", link = "Pmenu" }
hi { "PmenuSbar", link = "Pmenu" }
hi { "PmenuSel", link = "DraculaSelection" }
hi { "PmenuKindSel", link = "PmenuSel" }
hi { "PmenuExtraSel", link = "PmenuSel" }
hi { "PmenuThumb", link = "PmenuSel" }
hi { "WildMenu", link = "DraculaWildMenu" }

hi { "StatusLine", link = "DraculaStatusLine" }
hi { "StatusLineNC", link = "DraculaStatusLineNC" }
hi { "WinBar", link = "StatusLine" }
hi { "WinBarNC", link = "StatusLineNC" }

hi { "LineNr", link = "DraculaComment" }
hi { "LineNrAbove", link = "LineNr" }
hi { "LineNrBelow", link = "LineNr" }
hi { "CursorLineNr", link = "DraculaYellow" }

hi { "SignColumn", link = "DraculaComment" }
hi { "CursorLineSign", link = "SignColumn" }

hi { "FoldColumn", link = "DraculaSubtle" }
hi { "CursorLineFold", link = "FoldColumn" }

hi { "ModeMsg", link = "DraculaGreen" }
hi { "MatchParen", link = "DraculaGreenUnderline" }
hi { "Title", link = "DraculaGreenBold" }
-- This is unspecified in the source repo.
-- It should be a bug.
-- hi { "QuickFixLine" }

hi { "MsgArea" }

hi { "MsgSeparator", link = "StatusLine" }

hi { "MoreMsg", link = "DraculaFgBold" }

hi { "NormalFloat", link = "Pmenu" }
hi { "FloatBorder", link = "NormalFloat" }
hi { "FloatTitle", link = "Title" }
hi { "FloatFooter", link = "FloatTitle" }

hi { "Question", link = "DraculaFgBold" }

hi { "TabLine", link = "DraculaBoundary" }
hi { "TabLineFill", link = "DraculaBgDark" }
hi { "TabLineSel" }


-- :help group-name
hi { "Underlined", link = "DraculaFgUnderline" }
hi { "Tag", link = "DraculaCyan" }

hi { "Comment", link = "DraculaComment" }
hi { "SpecialComment", link = "DraculaCyanItalic" }
hi { "Todo", link = "DraculaTodo" }
hi { "Error", link = "DraculaError" }

hi { "Constant", link = "DraculaPurple" }
hi { "String", link = "DraculaYellow" }
hi { "Character", link = "DraculaPink" }
hi { "SpecialChar", link = "Special" }
hi { "Delimiter" }
hi { "Number", link = "Constant" }
hi { "Boolean", link = "Constant" }
hi { "Float", link = "Constant" }

hi { "Identifier" }
hi { "Function", link = "DraculaGreen" }

hi { "Keyword", link = "DraculaPink" }
hi { "Statement", link = "Keyword" }
hi { "Conditional", link = "Keyword" }
hi { "Repeat", link = "Keyword" }
hi { "Label", link = "Keyword" }
hi { "Operator", link = "Keyword" }
hi { "Exception", link = "Keyword" }
hi { "PreProc", link = "Keyword" }
hi { "Include", link = "Keyword" }
hi { "Define", link = "Keyword" }
hi { "Macro", link = "Keyword" }
hi { "PreCondit", link = "Keyword" }
hi { "StorageClass", link = "Keyword" }
hi { "Structure", link = "Keyword" }
hi { "Typedef", link = "Keyword" }

hi { "Type", link = "DraculaCyanItalic" }
hi { "Special", link = "DraculaPink" }
hi { "Debug", link = "Special" }

hi { "Added", link = "DraculaGreen" }
hi { "Changed", link = "DraculaDiffChange" }
hi { "Removed", link = "DraculaDiffDelete" }


-- :help diagnostic-highlights
hi { "DiagnosticError", link = "DraculaError" }
hi { "DiagnosticWarn", link = "DraculaWarn" }
hi { "DiagnosticInfo", link = "DraculaInfo" }
hi { "DiagnosticHint", link = "DraculaHint" }
hi { "DiagnosticOk", link = "DraculaOk" }

hi { "DiagnosticVirtualTextError", link = "DraculaErrorVirtualText" }
hi { "DiagnosticVirtualTextWarn", link = "DraculaWarnVirtualText" }
hi { "DiagnosticVirtualTextInfo", link = "DraculaInfoVirtualText" }
hi { "DiagnosticVirtualTextHint", link = "DraculaHintVirtualText" }
hi { "DiagnosticVirtualTextOk", link = "DraculaOkVirtualText" }

hi { "DiagnosticUnderlineError", link = "DraculaErrorLine" }
hi { "DiagnosticUnderlineWarn", link = "DraculaWarnLine" }
hi { "DiagnosticUnderlineInfo", link = "DraculaInfoLine" }
hi { "DiagnosticUnderlineHint", link = "DraculaHintLine" }
hi { "DiagnosticUnderlineOk", link = "DraculaOkLine" }

hi { "DiagnosticFloatingError", link = "DiagnosticError" }
hi { "DiagnosticFloatingWarn", link = "DiagnosticWarn" }
hi { "DiagnosticFloatingInfo", link = "DiagnosticInfo" }
hi { "DiagnosticFloatingHint", link = "DiagnosticHint" }
hi { "DiagnosticFloatingOk", link = "DiagnosticOk" }

hi { "DiagnosticSignError", link = "DiagnosticError" }
hi { "DiagnosticSignWarn", link = "DiagnosticWarn" }
hi { "DiagnosticSignInfo", link = "DiagnosticInfo" }
hi { "DiagnosticSignHint", link = "DiagnosticHint" }
hi { "DiagnosticSignOk", link = "DiagnosticOk" }

hi { "DiagnosticDeprecated", link = "Comment" }
hi { "DiagnosticUnnecessary", link = "Comment" }
