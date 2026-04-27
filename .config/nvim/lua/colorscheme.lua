-- Tema
-- vim.cmd.colorscheme "catppuccin-mocha"
-- This file isn't used anymore. Must remove 

local theme = require('onedark')

theme.setup({
  style = 'warmer'
})

theme.load()

-- Evitar resaltado en comentarios
-- local treesitter = require("nvim-treesitter.configs")

-- treesitter.setup({
--   highlight = {
--     enable = true,
--     additional_vim_regex_highlighting = false,
--     disable = function(lang, buf)
--       -- Aquí se pueden elegir algunos lenguajes específicos donde esta configuración no es necesaria
--       return false
--     end,
--   },
-- })

-- vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
