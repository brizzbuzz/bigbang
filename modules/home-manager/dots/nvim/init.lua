--[[

=====================================================================
=====================================================================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | .=o |          ========
========         ||     BRIZZ.NVIM     ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||                    ||   |:::::|          ========
========         |'-..................-'|   |_____|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ ~~~~~~~~ \     ========
========       /:::========|  |========:::\  \ ~~~~~~~~ \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

--]]

-- All the builtin config for neovim
require("custom.config")

-- Add custom file types
-- TODO: Find a better place for this
vim.filetype.add({ extension = { templ = "templ" } })

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Delegate all plugin configuration to the ./lua/custom/plugins directory
require("lazy").setup({
  { "folke/neodev.nvim", opts = {} }, -- Needs to be set up prior to LSP initialization
  { import = "custom.plugins" },
})
