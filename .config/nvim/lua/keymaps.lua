-- Símbolos LaTeX
vim.keymap.set("n", "<leader>ls", function()
  require("config.latex_symbols").show()
end, { desc = "Insertar símbolo LaTeX" })

vim.keymap.set("n", "<leader>lc", "<cmd>LatexCompile<CR>", {
  desc = "Compilar LaTeX",
})

require("config.tex_cmds")
