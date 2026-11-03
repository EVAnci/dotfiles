if vim.fn.executable("jdtls") ~= 1 then
  vim.notify("No se encontró jdtls en PATH", vim.log.levels.WARN)
  return
end

-- Prefer build roots over individual Maven modules in multi-module projects.
local root_dir = vim.fs.root(0, { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts" })
  or vim.fs.root(0, { "pom.xml", "build.gradle", "build.gradle.kts", ".git" })

if not root_dir then
  return
end

-- The hash keeps projects with the same directory name in separate workspaces.
local project_name = vim.fn.fnamemodify(root_dir, ":t")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/"
  .. project_name .. "-" .. vim.fn.sha256(root_dir):sub(1, 12)

require("jdtls").start_or_attach({
  cmd = { "jdtls", "-data", workspace_dir },
  root_dir = root_dir,
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  on_attach = function(client, bufnr)
    require("config.lsp").on_attach(client, bufnr)
    vim.keymap.set("n", "<leader>jo", require("jdtls").organize_imports,
      { buffer = bufnr, desc = "Organizar imports Java" })
  end,
})
