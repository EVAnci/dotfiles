local symbols = {
  -- Letras griegas minúsculas
  { symbol = "α", latex = "\\alpha" },
  { symbol = "β", latex = "\\beta" },
  { symbol = "𝛾", latex = "\\gamma" },
  { symbol = "𝜹", latex = "\\delta" },
  { symbol = "𝝐", latex = "\\epsilon" },
  { symbol = "𝜻", latex = "\\zeta" },
  { symbol = "𝜼", latex = "\\eta" },
  { symbol = "θ", latex = "\\theta" },
  { symbol = "𝜾", latex = "\\iota" },
  { symbol = "𝜿", latex = "\\kappa" },
  { symbol = "λ", latex = "\\lambda" },
  { symbol = "μ", latex = "\\mu" },
  { symbol = "𝝂", latex = "\\nu" },
  { symbol = "𝝃", latex = "\\xi" },
  { symbol = "π", latex = "\\pi" },
  { symbol = "𝞺", latex = "\\rho" },
  { symbol = "𝜎", latex = "\\sigma" },
  { symbol = "𝜏", latex = "\\tau" },
  { symbol = "𝜐", latex = "\\upsilon" },
  { symbol = "𝜙", latex = "\\phi" },
  { symbol = "𝜘", latex = "\\chi" },
  { symbol = "𝜓", latex = "\\psi" },
  { symbol = "𝜔", latex = "\\omega" },
  
  -- Variables griegas minúsculas
  { symbol = "ε", latex = "\\varepsilon" },
  { symbol = "𝜗", latex = "\\vartheta" },
  { symbol = "𝜛", latex = "\\varpi" },
  { symbol = "𝜚", latex = "\\varrho" },
  { symbol = "𝜑", latex = "\\varphi" },

  -- Letras griegas mayúsculas
  { symbol = "𝚪", latex = "\\Gamma" },
  { symbol = "𝚫", latex = "\\Delta" },
  { symbol = "𝚯", latex = "\\Theta" },
  { symbol = "𝚲", latex = "\\Lambda" },
  { symbol = "𝚵", latex = "\\Xi" },
  { symbol = "𝚷", latex = "\\Pi" },
  { symbol = "𝚺", latex = "\\Sigma" },
  { symbol = "𝚼", latex = "\\Upsilon" },
  { symbol = "𝚽", latex = "\\Phi" },

  -- Variables griegas mayúsculas
  { symbol = "𝛤", latex = "\\varGamma" },
  { symbol = "𝛥", latex = "\\varDelta" },
  { symbol = "𝛩", latex = "\\varTheta" },
  { symbol = "𝛬", latex = "\\varLambda" },
  { symbol = "𝛯", latex = "\\varXi" },
  { symbol = "𝛱", latex = "\\varPi" },
  { symbol = "𝛴", latex = "\\varSigma" },
  { symbol = "𝛶", latex = "\\varUpsilon" },
  { symbol = "𝛷", latex = "\\varPhi" },
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
