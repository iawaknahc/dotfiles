-- :highlight clear resets to default, not clear everything.
-- vim.api.nvim_set_hl does replace everything.
-- TODO: Investigate why TODO has incorrect highlight
-- TODO: Support vim-gitgutter
-- TODO: Support lualine

-- hsl(0, 0%, 5%)
-- Darker than background
local darker_than_background = "#0D0D0D"

-- hsl(0, 0%, 10%)
-- Background
local background = "#1A1A1A"

-- hsl(0, 0%, 35%)
-- Selection
local selection = "#595959"

-- hsl(0, 0%, 60%)
-- Comment
local comment = "#999999"

-- hsl(0, 0%, 99%)
-- Foreground
local foreground = "#FCFCFC"

-- hsl(0, 80%, 60%)
-- Error, deleted
local red = "#EB4747"

-- hsl(60, 80%, 60%)
-- Warning, changed, highlight, search other
local yellow = "#EBEB47"

-- hsl(120, 80%, 60%)
-- OK, added, search current, match paren, title
local green = "#47EB47"

-- hsl(180, 60%, 80%)
-- Info, special, Special comment, constant, type
local cyan = "#ADEBEB"

-- hsl(240, 60%, 80%)
-- Hint, separator
local blue = "#ADADEB"

-- hsl(300, 60%, 80%)
-- Keyword
local magenta = "#EBADEB"


vim.cmd[[
hi! clear
]]
vim.o.background = 'dark'

local function hi(opts)
  local name = opts[1]
  opts[1] = nil
  vim.api.nvim_set_hl(0, name, opts)
end


-- :help highlight-groups
hi { "Normal", bg = background, fg = foreground }
hi { "Directory" }

hi { "ColorColumn", bg = darker_than_background }

hi { "NonText", fg = comment, bold = true }
hi { "EndOfBuffer", link = "NonText" }
hi { "Conceal", link = "NonText" }
hi { "NormalNC", link = "NonText" }
hi { "Whitespace", link = "NonText" }
hi { "SpecialKey", link = "NonText" }

hi { "CurSearch", fg = green, reverse = true }
hi { "Search", fg = yellow, reverse = true }
hi { "IncSearch", link = "Search" }
hi { "Substitute", link = "Search" }

hi { "Cursor", reverse = true }
hi { "lCursor", link = "Cursor" }
hi { "CursorIM", link = "Cursor" }
hi { "TermCursor", link = "Cursor" }
hi { "TermCursorNC" }

hi { "Visual", bg = selection }
hi { "CursorColumn", link = "Visual" }
hi { "CursorLine", link = "Visual" }
hi { "VisualNOS" }
hi { "SnippetTabstop", link = "Visual" }

hi { "DiffAdd", fg = green }
hi { "DiffChange", fg = yellow }
hi { "DiffDelete", fg = red }
hi { "DiffText", fg = yellow }

hi { "ErrorMsg", fg = red, reverse = true }
hi { "WarningMsg", fg = yellow, reverse = true }

hi { "SpellBad", sp = red, undercurl = true }
hi { "SpellRare", sp = yellow, undercurl = true }
hi { "SpellCap", link = "SpellBad" }
hi { "SpellLocal", link = "SpellRare" }

hi { "WinSeparator", bg = darker_than_background, fg = blue }
hi { "Folded", link = "WinSeparator" }

hi { "Pmenu", bg = darker_than_background }
hi { "PmenuKind", link = "Pmenu" }
hi { "PmenuExtra", link = "Pmenu" }
hi { "PmenuSbar", link = "Pmenu" }
hi { "PmenuSel", link = "Visual" }
hi { "PmenuKindSel", link = "PmenuSel" }
hi { "PmenuExtraSel", link = "PmenuSel" }
hi { "PmenuThumb", link = "PmenuSel" }
hi { "WildMenu", link = "PmenuSel" }

hi { "StatusLine", bg = selection, bold = true }
hi { "StatusLineNC", bg = darker_than_background, fg = comment }
hi { "WinBar", link = "StatusLine" }
hi { "WinBarNC", link = "StatusLineNC" }

hi { "LineNr", fg = comment }
hi { "LineNrAbove", link = "LineNr" }
hi { "LineNrBelow", link = "LineNr" }
hi { "CursorLineNr", bold = true }

hi { "SignColumn", link = "LineNr" }
hi { "CursorLineSign", link = "SignColumn" }

hi { "FoldColumn", link = "LineNr" }
hi { "CursorLineFold", link = "FoldColumn" }

hi { "ModeMsg", fg = green }
hi { "MatchParen", fg = green, underline = true }
hi { "Title", fg = green, bold = true }
hi { "QuickFixLine", fg = green }

hi { "MsgArea" }

hi { "MsgSeparator", link = "StatusLine" }

hi { "MoreMsg", bold = true }

hi { "NormalFloat", link = "Pmenu" }
hi { "FloatBorder", link = "NormalFloat" }
hi { "FloatTitle", link = "Title" }
hi { "FloatFooter", link = "FloatTitle" }

hi { "Question", bold = true }

hi { "TabLine", link = "WinSeparator" }
hi { "TabLineFill", bg = darker_than_background }
hi { "TabLineSel" }


-- :help group-name
hi { "Underlined", underline = true }
hi { "Tag", link = "Underlined" }

hi { "Comment", fg = comment }
hi { "SpecialComment", fg = cyan, italic = true }
hi { "Todo", fg = yellow, reverse = true }
hi { "Error", fg = red, reverse = true }

hi { "Constant", fg = cyan }
hi { "String", link = "Constant" }
hi { "Character", link = "Constant" }
hi { "SpecialChar", link = "Constant" }
hi { "Delimiter", link = "Constant" }
hi { "Number", link = "Constant" }
hi { "Boolean", link = "Constant" }
hi { "Float", link = "Constant" }

hi { "Identifier" }
hi { "Function", link = "Identifier" }

hi { "Keyword", fg = magenta }
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
hi { "Debug", link = "Keyword" }
hi { "Structure", link = "Keyword" }
hi { "Typedef", link = "Keyword" }

hi { "Type", fg = cyan }
hi { "Special", fg = cyan }

hi { "Added", fg = green }
hi { "Changed", fg = yellow }
hi { "Removed", fg = red }


-- :help diagnostic-highlights
hi { "DiagnosticError", fg = red }
hi { "DiagnosticWarn", fg = yellow }
hi { "DiagnosticInfo", fg = cyan }
hi { "DiagnosticHint", fg = blue }
hi { "DiagnosticOk", fg = green }

hi { "DiagnosticVirtualTextError", fg = red, italic = true }
hi { "DiagnosticVirtualTextWarn", fg = yellow, italic = true }
hi { "DiagnosticVirtualTextInfo", fg = cyan, italic = true }
hi { "DiagnosticVirtualTextHint", fg = blue, italic = true }
hi { "DiagnosticVirtualTextOk", fg = green, italic = true }

hi { "DiagnosticUnderlineError", sp = red, undercurl = true }
hi { "DiagnosticUnderlineWarn", sp = yellow, undercurl = true }
hi { "DiagnosticUnderlineInfo", sp = cyan, undercurl = true }
hi { "DiagnosticUnderlineHint", sp = blue, undercurl = true }
hi { "DiagnosticUnderlineOk", sp = green, undercurl = true }

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
