-- Set the leader key early (before plugins/keymaps)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Boostrap the main configuration
require("yoda.config")


-- Define the path to your private extensions
local private_dir = vim.fn.expand("~/private-nvim-extensions/")

--  Check if the private directory exists
if vim.fn.isdirectory(private_dir) == 1 then
  -- Extend Lua's package.path to include the private directory
  package.path = package.path .. ";" .. private_dir .. "?.lua;" .. private_dir .. "?/init.lua"

  -- Safely require the private init.lua
  pcall(require, "init")
end

