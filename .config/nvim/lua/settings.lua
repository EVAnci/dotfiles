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
set.shiftwidth = 2              -- Cantidad de espacios para un nivel de indentación
set.expandtab = true            -- Tabular inserta espacios no \t
set.termguicolors = true        -- Requerido por bufferline 
set.wrap = true
set.linebreak = true            -- Wrap en espacios, no a mitad de palabra
set.breakindent = true          -- Indenta la línea envuelta
set.showbreak = '↪ '            -- Indicador visual de línea envuelta (opcional)

vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })

-- Mover con j/k en vez de saltar a toda la línea lógica:
vim.keymap.set('n', 'j', 'gj', { noremap = true, silent = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true, silent = true })

-- Esta función me permite convertir una linea normal como 3 4 5 en $3$ & $4$ & $5$.
vim.api.nvim_create_user_command("LatexRow", function()
  local line = vim.fn.getline(".")
  local result = {}
  for word in line:gmatch("%S+") do
    table.insert(result, "$" .. word .. "$")
  end
  local transformed = table.concat(result, " & ") .. " \\\\"
  vim.fn.setline(".", transformed)
end, {})
