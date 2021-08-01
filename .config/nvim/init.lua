vim.cmd [[
" :help nvim-from-vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

set inccommand=nosplit

augroup MyNeovimAutocommands
  autocmd!
  " https://neovim.io/news/2021/07
  autocmd TextYankPost * lua vim.highlight.on_yank()
augroup END
]]

require('plugins')
