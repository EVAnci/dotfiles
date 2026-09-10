
vim.api.nvim_create_user_command("LatexFixDisplay", function()
  vim.cmd([[
    %s/\$\$\_s*\(\_.\{-}\)\_s*\$\$/\\[\r\1\r\\]/g
  ]])
end, {})

vim.api.nvim_create_user_command("LatexFixInline", function()
  vim.cmd([[
    %s/\$\([^$\n]\{-}\)\$/\\(\1\\)/g
  ]])
end, {})

vim.api.nvim_create_user_command("LatexFixAll", function()
  vim.cmd("LatexFixDisplay")
  vim.cmd("LatexFixInline")
end, {})

vim.api.nvim_create_user_command("LatexFixQuotes", function()
  vim.cmd([[
    %s/"\([^"]*\)"/``\1''/g   
  ]])
end, {})

vim.api.nvim_create_user_command("OpenPdf", function(opts)
  local file = opts.args ~= "" and opts.args or "main.pdf"

  vim.fn.jobstart({ "xdg-open", file }, {
    detach = true,
  })
end, {
  nargs = "?",
  complete = "file",
})

vim.api.nvim_create_user_command("LatexCompile", function()
  local file = vim.fn.expand("%:p")

  if file == "" then
    vim.notify("No hay un archivo abierto", vim.log.levels.ERROR)
    return
  end

  local dir = vim.fn.fnamemodify(file, ":h")
  local name = vim.fn.fnamemodify(file, ":t")

  vim.cmd("botright 15split")
  vim.cmd("enew")

  vim.fn.jobstart({ "lualatex", name }, {
    term = true,
    cwd = dir,
  })
end, {
  desc = "Compilar el archivo actual con LuaLaTeX",
})
