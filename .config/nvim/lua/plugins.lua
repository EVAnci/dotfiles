-- Este bloque le dice a `lazy.nvim` qué plugins debe instalar y cargar. Es el catálogo de plugins
-- que usará la configuración de nvim
--
-- Cada entrada es una tabla lua con:
-- * El nombre del repositorio GitHub ("autor/plugin")
-- * Opcionalmente, opciones como:
--   * name : nombre interno
--   * priority : orden de carga
--   * dependecies : otros plugins que necesita
--   * config = function() ... end : configuración personalizada del pugin
--
-- En este bloque no se configuran los plugins aún, simplemente los declara para que se descarguen
-- y gestionen.

require("lazy").setup({
  -- Tema visual
  -- { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "navarasu/onedark.nvim", priority = 1000 },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Explorador de archivos
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Autocompletado y snippets
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },
  
  -- LSP (Lenguaje para python, latex, etc.
  { "neovim/nvim-lspconfig" },

  -- Soporte para latex
  { "lervag/vimtex" },

  -- Comentarios y corrección ortográfica
  { "tpope/vim-commentary" },

  -- Barra de estado elegante
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
})
