
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
