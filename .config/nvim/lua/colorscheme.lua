-- Tema
-- vim.cmd.colorscheme "catppuccin-mocha"

local theme = require('onedark')

theme.setup({
  style = 'warm'
})

vim.cmd.colorscheme 'onedark'

-- Evitar resaltado en comentarios
local treesitter = require("nvim-treesitter.configs")

treesitter.setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
    disable = function(lang, buf)
      -- Aquí se pueden elegir algunos lenguajes especificos donde esta configuración no es necesaria
      return false
    end,
  },
})

vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
