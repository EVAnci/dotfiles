-- Archivo de configuración general
-- Aquí se definen opciones globales de vim, que afectan el comportamiento general del editor
-- Estas configuraciones son equivalentes a las que se colocaban en .vimrc

local set = vim.opt

set.number = true               -- Mostrar número de linea
set.relativenumber = true       -- Mostrar números relativos
set.termguicolors = true        -- Activar colores mejorados
set.spelllang = "es"            -- Ortografía en español {"es", "en"} se pueden agregar más
set.spell = true                -- Activar corrección ortográfica
set.mouse = "a"                 -- Activar ratón
set.tabstop = 2                 -- Cantidad de caracteres que representa \t (tab)
set.shiftwidth = 2            -- Cantidad de espacios para un nivel de indentación
set.expandtab = true          -- Tabular inserta espacios no \t

vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })
