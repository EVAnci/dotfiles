local cmp = require("cmp")
local luasnip = require("luasnip")

-- Carga de snippets personalizados
require("luasnip.loaders.from_lua").lazy_load({ paths = "~/.config/nvim/lua/snippets/" })

-- Snippets estilo vscode
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(), -- Activar menú de autocompletado
    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter para confirmar
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  -- Fuentes (sources) POR DEFECTO para todos los tipos de archivo
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),

  -- La configuración específica por tipo de archivo va aquí DENTRO.
  filetype = {
    -- La clave es el tipo de archivo, p.ej. 'tex'
    ['tex'] = {
      -- Sobrescribimos las 'sources' solo para archivos 'tex'
      sources = cmp.config.sources({
        { name = 'luasnip' },
        { name = 'nvim_lsp' },
        -- 'buffer' está excluido, tal como querías
      }),
    }
    -- Podrías añadir más aquí, ej: ['python'] = { ... }
  },
  

  -- Ventanas flotantes de completado
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },

  formatting = {
    format = function(entry, vim_item)
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        buffer = "[Buf]",
        path = "[Path]",
        luasnip = "[Snip]",
      })[entry.source.name]
      return vim_item
    end,
  },
})

-- Auto pair para cmp
local cmp_autopairs = require("nvim-autopairs.completion.cmp")

cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
