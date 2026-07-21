local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("\\fig", {
    t({ "\\begin{figure}[!ht]", 
    "  \\centering",}),
    t({ "  \\caption{" }),
    i(1, ""),
    t({ "}", "  \\label{fig:" }),
    i(2, ""),
    t({ "}", "\\end{figure}" }),
  }),

  s("\\abs", {
    t({ "\\left\\lvert " }),
    i(1,"expr"),
    t({ "\\right\\rvert" }),
  }),

  s("\\pesc", {
    t({ "\\left\\langle " }),
    i(1,"expr"),
    t({ "\\right\\rangle" }),
  }),
}
