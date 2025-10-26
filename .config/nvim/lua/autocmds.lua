vim.api.nvim_create_autocmd("FileType", {
  
  -- El "patrón" es el tipo de archivo que queremos que lo active
  pattern = "tex",
  
  -- El "callback" es la función que se ejecuta
  callback = function()
    -- ¡La clave es "opt_local"!
    -- Esto activa la corrección ortográfica SOLO para este búfer.
    vim.opt_local.spell = true
  end,
})

-- Si en el futuro quieres añadir más tipos de archivo (ej. Markdown):
-- pattern = { "tex", "markdown" },
