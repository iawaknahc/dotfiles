vim.opt.diffopt = {
  "internal",
  "indent-heuristic",
  "algorithm:histogram",
  "closeoff",
  "filler",
  "foldcolumn:1",
  "linematch:60",
  "inline:word",
  "vertical",
}

vim.cmd([[packadd nvim.difftool]])
