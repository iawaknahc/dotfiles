vim.cmd([[
" Add `:` to iskeyword so that `:help *` on an account name searches the account name, not the account name component.
setlocal iskeyword+=:
" Add `-` to iskeyword so that `:help *` on a signed amount searches the whole signed amount.
setlocal iskeyword+=-
" Add `.` to iskeyword so that `:help *` on an amount with decimal point searches the whole amount.
setlocal iskeyword+=.
" Add `#` to iskeyword so that `:help *` on a tag searches the tag.
setlocal iskeyword+=#
" Add `^` to iskeyword so that `:help *` on a tag searches the link.
setlocal iskeyword+=^
]])
