-- First as this file will be loaded in plugins file, we define a variable
local M = {}

-- Define keymaps to work with the lsp 
function M.on_attach(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("n", "gd", vim.lsp.buf.definition, "Ir a definición")
  map("n", "K", vim.lsp.buf.hover, "Documentación flotante")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Renombrar símbolo")
  map("n", "gr", vim.lsp.buf.references, "Buscar referencias")
  map("n", "[d", vim.diagnostic.goto_prev, "Error anterior")
  map("n", "]d", vim.diagnostic.goto_next, "Siguiente error")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Acciones disponibles")
end

-- Define a custom command to remember the commands
vim.api.nvim_create_user_command("HelpLSP", function()
  local ayuda = [[
Available LSP Commands:

Normal mode:
  gd            -> Go to definition
  K             -> Floating documentation
  gr            -> Find references
  <leader>rn    -> Rename symbol (<leader> = \)
  <leader>ca    -> See available actions
  [d            -> Previous error
  ]d            -> Next error

Extra:
  :LspInfo      -> View status of active LSPs
  :HelpLSP      -> This message
  ]]
  vim.notify(ayuda, vim.log.levels.INFO, { title = "Ayuda LSP" })
end, {})

return M
