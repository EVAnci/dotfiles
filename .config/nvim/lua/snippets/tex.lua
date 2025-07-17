local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("\\fig", {
    t({ "\\begin{figure}[ht]", 
    "  \\centering", 
    "  \\includegraphics[width=" }),
    i(1, "\\linewidth"),
    t({ "]{" }),
    i(2, "ruta/imagen"),
    t({ "}", "  \\caption{" }),
    i(3, "Descripción"),
    t({ "}", "  \\label{fig:" }),
    i(4, "etiqueta"),
    t({ "}", "\\end{figure}" }),
  }),

  s("\\align", {
    t({ "\\begin{align*}", "  " }),
    i(1, "equation"),
    t({ "", "\\end{align*}" }),
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
