-- Pluggin manager: lazy.nvim

-- We define the path where the pluggins will be stored. 
-- In this case will be ~/.local/share/nvim/lazy/
-- And the pluggin manager (lazy) will be in ./lazy/lazy.nvim
-- This is just a variable, we are not downloading anything yet.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Check if lazy manager is already installed
-- If not, then is installed
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
-- Add lazy.nvim to the runtime path
vim.opt.rtp:prepend(lazypath)

-- Here we import all files located at ./lua directory
require("plugins")
require("settings")
require("keymaps")
