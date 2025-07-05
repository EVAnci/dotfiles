-- Archivo de configuración general
-- Aquí se definen opciones globales de vim, que afectan el comportamiento general del editor
-- Estas configuraciones son equivalentes a las que se colocaban en .vimrc

vim.o.number = true               -- Mostrar número de linea
vim.o.relativenumber = true       -- Mostrar números relativos
vim.o.termguicolors = true        -- Activar colores mejorados
vim.o.spelllang = "es"            -- Ortografía en español {"es", "en"} se pueden agregar más
vim.o.spell = true                -- Activar correción ortográfica
vim.o.mouse = "a"                 -- Activar mouse
vim.o.tabstop = 2                 -- Cantidad de caracteres que representa \t (tab)
vim.opt.shiftwidth = 2            -- Cantidad de espacios para un nivel de identación
vim.opt.expandtab = true          -- Tabular inserta espacios no \t
