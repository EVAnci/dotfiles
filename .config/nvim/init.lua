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
local lspconfig = require("lspconfig")
lspconfig.pyright.setup{}
lspconfig.texlab.setup{}
