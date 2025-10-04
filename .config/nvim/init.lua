-- Gestor de plugins: lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Si no está lazy.nvim se descarga
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
-- Agregar lazy.nvim al runtime path
vim.opt.rtp:prepend(lazypath)

require("plugins")
require("settings")
require("colorscheme")
require("config.cmp")

-- Configuración de barra de estado
require("lualine").setup()

-- Configuración de explorador de archivos
require("nvim-tree").setup()

-- Configuración de LSP para Python y Latex
vim.lsp.config('pyright', {
  filetypes = { 'py' }
})
vim.lsp.config('texlab', {
  filetype = { 'tex' }
})
vim.lsp.enable({'pyright', 'texlab'})


-- The following old configuration is deprecated. File ./config/lsp.lua is ignored
-- local lspconfig = require('lspconfig')
-- lspconfig.pyright.setup{}
-- lspconfig.texlab.setup{}

-- Configuración de Configuración de lsp (pyright, texlab)
-- require("config.lsp")

-- Configuración de auto pair (corchetes, parentesis, comillas)
require("config.autopairs")

-- Configuración de git_signs
require("config.git_signs")

-- Configuración recomendada de Bufferline
require("config.bufferline")

-- Símbolos LaTeX
vim.keymap.set("n", "<leader>ls", function()
  require("config.latex_symbols").show()
end, { desc = "Insertar símbolo LaTeX" })
