local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local function feature_name()
  return vim.fn.expand("%:t:r")
end

return {
  s(
    "elispfeature",
    fmt(
      [[
      ;;; {2}.el --- {2}.el -*- lexical-binding: t -*-
      ;;; Commentary:
      ;;; Code:

      {1}

      (provide '{2})
      ;;; {2}.el ends here
    ]],
      {
        i(0),
        f(feature_name),
      }
    )
  ),
}
