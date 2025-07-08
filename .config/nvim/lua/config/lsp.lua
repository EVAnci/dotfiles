local lspconfig = require("lspconfig")

local on_attach = function(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map ("n", "gd", vim.lsp.buf.definition, "Ir a definición")
  map("n", "K", vim.lsp.buf.hover, "Documentación flotante")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Renombrar símbolo")
  map("n", "gr", vim.lsp.buf.references, "Buscar referencias")
  map("n", "[d", vim.diagnostic.goto_prev, "Error anterior")
  map("n", "]d", vim.diagnostic.goto_next, "Siguiente error")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Acciones disponibles")
end

-- Configuración para pyright
lspconfig.pyright.setup({
  on_attach = on_attach,
})

-- Configuración para texlab
lspconfig.texlab.setup({
  on_attach = on_attach,
})

vim.api.nvim_create_user_command("AyudaLSP", function()
  local ayuda = [[
Comandos LSP disponibles:

Normal mode:
  gd            -> Ir a definición
  K             -> Documentación flotante
  gr            -> Buscar referencias
  <leader>rn    -> Renombrar símbolo (<leader> = \)
  <leader>ca    -> Ver acciones disponibles
  [d            -> Error anterior
  ]d            -> Siguiente error

Extra:
  :LspInfo      -> Ver estado de los LSP activos
  :ayudalsp     -> Este mensaje
  ]]
  vim.cmd("new")          -- nuevo buffer
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(ayuda,"\n"))
  vim.bo.buflisted = false
  vim.bo.buftype = "nofile"
  vim.bo.swapfile = false
  vim.bo.bufhidden = "wipe"
  vim.bo.modifiable = false
end, {})
