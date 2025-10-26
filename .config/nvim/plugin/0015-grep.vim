" We used to follow the suggestion from
" https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3#enlightenment
" But the suggestion there does not handle escape character very well.
" For example, it is impossible to :Grep \\\(
" So we now follow the suggestion from :help grep

command! -nargs=+ -complete=file_in_path Grep  execute 'silent grep!  <args>'
command! -nargs=+ -complete=file_in_path LGrep execute 'silent lgrep! <args>'

cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'

augroup quickfix
  autocmd!
  autocmd QuickFixCmdPost grep,helpgrep,vimgrep cwindow | set nowinfixheight
  autocmd QuickFixCmdPost lgrep,lhelpgrep,lvimgrep lwindow | set nowinfixheight
augroup END
