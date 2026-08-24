-- How to add a plugin? Easy, search for the plugin on a web browser. Then, usually 
-- pluggins have the way to install it with lazy. But in case is not shown, 
-- the below text is the way.
--
-- This block tells 'lazy' (who is the plugin manager) which plugins has to install and load.
-- This file is kinda plugin catalog of nvim config.
--
-- Each entry is a lua table:
-- * The name of the repo (GitHub) -> ('user/plugin')
-- * Optionally, options like:
--    * name : (like for the theme)
--    * priority : load order (higher = later)
--    * dependecies : other plugins necessary for the plugin to work
--    * config = function() ... end : the configuration of the plugin

-- Here start the plugin setup
require("lazy").setup({

  -- Syntax highlighting and parsers used by render-markdown.nvim
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",

    config = function()
      local treesitter = require("nvim-treesitter")

      -- Autoinstall missing parsers.
      treesitter.install({
        "markdown",
        "markdown_inline",
        "lua",
        "python",
        "java",
        "c",
        "bash",
        "latex",
        "json",
      })

      -- Activate treesitter for this filetype
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "markdown",
          "lua",
          "python",
          "java",
          "c",
          "sh",
          "tex",
          "json",
        },
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },

  -- Render Markdown headings, bullets and checkboxes inside Neovim
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      heading = {
        enabled = true,
        sign = true,
        style = "full",
        icons = { "① ", "② ", "③ ", "④ ", "⑤ ", "⑥ " },
        left_pad = 1,
      },
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
        right_pad = 1,
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 " },
        },
      },
    },
  },


  -- A completion engine plugin 
  { 
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function() 
      require("config.cmp")
    end 
  },

  -- LSP (Language Server Protocol)
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local lspcfg = require('config.lsp')
      
      vim.lsp.config('pyright', {
        on_attach = lspcfg.on_attach
      })
      vim.lsp.config('texlab', {
        on_attach = lspcfg.on_attach
      })
      
      vim.lsp.enable({'pyright','texlab'})
    end
  },

  -- filetype and syntax plugin for LaTeX files. 
  -- For more info read .config/nvim/docs/plugins/VimTeX.md
   {
    "lervag/vimtex",
    lazy = false,
    -- tag = "v2.15", -- uncomment to pin to a specific release
    -- init = function()
    --   -- VimTeX configuration goes here, e.g.
    --   vim.g.vimtex_view_method = "zathura"
    -- end
  },

  -- Plugin for comment multiple lines with gc
  { 
    "tpope/vim-commentary" 
  },

  -- The bottom status bar enhanced
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup()
    end
  },

  -- A file explorer for neovim
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        git = {
            enable = true,
            ignore = false,
      },
    })
    end
  },

  -- Auto pairing
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("config.autopairs")
    end
  },

  -- Telescope
  { 
    "nvim-telescope/telescope.nvim", 
    dependencies = { "nvim-lua/plenary.nvim" } 
  },

  -- Git sign (mostrar cambios de git)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("config.git_signs")
    end
  },

  -- Bufferline (upper tabs)
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("config.bufferline")
    end
  },

  -- The most important config: the visual theme xD
  { 
    "navarasu/onedark.nvim", 
    priority = 1000,
    config = function()
      require("colorscheme")
    end 
  }
})
