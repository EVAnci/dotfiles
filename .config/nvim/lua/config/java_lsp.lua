local M = {}

-- Session-only switch: Java LSP starts enabled on each Neovim launch.
local enabled = true

function M.start()
  if not enabled then
    return
  end

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
end

function M.setup()
  vim.api.nvim_create_user_command("JavaLspOff", function()
    enabled = false
    vim.lsp.stop_client(vim.lsp.get_clients({ name = "jdtls" }))
    vim.notify("LSP Java desactivado para esta sesión")
  end, { desc = "Detener Java LSP y bloquear su inicio automático" })

  vim.api.nvim_create_user_command("JavaLspOn", function()
    enabled = true
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "java" then
        vim.api.nvim_buf_call(bufnr, M.start)
      end
    end
    vim.notify("LSP Java habilitado para esta sesión")
  end, { desc = "Habilitar Java LSP y conectarlo a los archivos Java abiertos" })
end

return M
