-- Minimal init.lua for running tests
-- This ensures tests run in a clean environment

-- Get the root directory
local root = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")

-- Add lua/ to runtimepath so tests can require modules
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:append(root .. "/lua")

-- Set up package.path to find yoda modules
package.path = package.path .. ";" .. root .. "/lua/?.lua"
package.path = package.path .. ";" .. root .. "/lua/?/init.lua"

-- Add luarocks path for coverage (LuaCov)
-- Directly add common luarocks paths
local home = os.getenv("HOME")
if home then
  package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.4/?.lua"
  package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.4/?/init.lua"
  package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.3/?.lua"
  package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.3/?/init.lua"
  package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.1/?.lua"
  package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.1/?/init.lua"
  
  package.cpath = package.cpath .. ";" .. home .. "/.luarocks/lib/lua/5.4/?.so"
  package.cpath = package.cpath .. ";" .. home .. "/.luarocks/lib/lua/5.3/?.so"
  package.cpath = package.cpath .. ";" .. home .. "/.luarocks/lib/lua/5.1/?.so"
end

-- Minimal Neovim settings for testing
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false

-- Disable plugins we don't need for tests
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1

-- Bootstrap lazy.nvim for tests
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Install only plenary for tests
require("lazy").setup({
  {
    "nvim-lua/plenary.nvim",
    lazy = false,
  },
}, {
  install = {
    missing = true,
  },
  ui = {
    border = "rounded",
  },
})
