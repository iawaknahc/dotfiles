local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s(
    ">note",
    fmt(
      [[
        > [!NOTE]
        > {}
      ]],
      { i(0) }
    )
  ),
  s(
    ">tip",
    fmt(
      [[
        > [!TIP]
        > {}
      ]],
      { i(0) }
    )
  ),
  s(
    ">warning",
    fmt(
      [[
        > [!WARNING]
        > {}
      ]],
      { i(0) }
    )
  ),
  s(
    ">important",
    fmt(
      [[
        > [!IMPORTANT]
        > {}
      ]],
      { i(0) }
    )
  ),
}
