_G.manoption_helper = function()
  -- Delete the space that triggered the abbreviation.
  local c = vim.fn.getcmdline()
  c = string.sub(c, 1, -2)
  vim.fn.setcmdline(c)
end

-- This abbreviation helps finding the definition of an option in a manpage.
--
-- ^\s*
-- The simplest case
--   -i
-- (,| or )\s*
-- As seen in the manpage of fish, or the manpage of openssl
--   -i or --interactive
--  -i, --interactive
-- [-+|]+\s*
-- As seen in the manpage of lsof
--   +|-E
vim.cmd([[
cnoreabbrev <expr> -- (getcmdtype() ==# '/') ? '\v\C(^\s*<Bar>(,<Bar> or )\s*<Bar>[-+<Bar>]+\s*)\zs<lt>\V<C-R>=lua:manoption_helper()<CR>' : '--'
]])
