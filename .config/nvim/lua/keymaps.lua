-- Símbolos LaTeX
vim.keymap.set("n", "<leader>ls", function()
  require("config.latex_symbols").show()
end, { desc = "Insertar símbolo LaTeX" })
