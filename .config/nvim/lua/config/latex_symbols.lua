
-- ~/.config/nvim/lua/config/latex_symbols.lua


local symbols = {
  -- Letras griegas
  { symbol = "α", latex = "\\alpha" },
  { symbol = "β", latex = "\\beta" },
  { symbol = "γ", latex = "\\gamma" },
  { symbol = "Δ", latex = "\\Delta" },
  { symbol = "ε", latex = "\\varepsilon" },
  { symbol = "θ", latex = "\\theta" },
  { symbol = "λ", latex = "\\lambda" },
  { symbol = "μ", latex = "\\mu" },
  { symbol = "π", latex = "\\pi" },
  { symbol = "Ω", latex = "\\Omega" },

  -- Operadores matemáticos
  { symbol = "∑", latex = "\\sum" },
  { symbol = "∏", latex = "\\prod" },
  { symbol = "∫", latex = "\\int" },
  { symbol = "∇", latex = "\\nabla" },
  { symbol = "∞", latex = "\\infty" },
  { symbol = "∂", latex = "\\partial" },

  -- Flechas
  { symbol = "→", latex = "\\rightarrow" },
  { symbol = "←", latex = "\\leftarrow" },
  { symbol = "↦", latex = "\\mapsto" },
  { symbol = "⇒", latex = "\\Rightarrow" },
  { symbol = "⇔", latex = "\\Leftrightarrow" },

  -- Conjuntos y lógica
  { symbol = "∈", latex = "\\in" },
  { symbol = "∉", latex = "\\notin" },
  { symbol = "⊂", latex = "\\subset" },
  { symbol = "⊆", latex = "\\subseteq" },
  { symbol = "∪", latex = "\\cup" },
  { symbol = "∩", latex = "\\cap" },
  { symbol = "¬", latex = "\\neg" },
  { symbol = "∧", latex = "\\wedge" },
  { symbol = "∨", latex = "\\vee" },
  { symbol = "⊢", latex = "\\vdash" },
  { symbol = "⊨", latex = "\\models" },

  -- Conjuntos numéricos
  { symbol = "ℕ", latex = "\\mathbb{N}" },
  { symbol = "ℤ", latex = "\\mathbb{Z}" },
  { symbol = "ℚ", latex = "\\mathbb{Q}" },
  { symbol = "ℝ", latex = "\\mathbb{R}" },
  { symbol = "ℂ", latex = "\\mathbb{C}" },
}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local M = {}

M.show = function()
  pickers.new({}, {
    prompt_title = "Símbolos LaTeX",
    finder = finders.new_table {
      results = symbols,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.symbol .. "  →  " .. entry.latex,
          ordinal = entry.latex,
        }
      end
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(_, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close()
        vim.api.nvim_put({ selection.value.latex }, "", true, true)
      end)
      return true
    end,
  }):find()
end

return M
