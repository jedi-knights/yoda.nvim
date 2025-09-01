-- Set the leader key early (before plugins/keymaps)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Database configuration (can be overridden in local config)
vim.g.dbs = vim.g.dbs or {}

-- Boostrap the main configuration
require("yoda")

-- Define a function to print and return a value
function _G.P(v)
  print(vim.inspect(v))
  return v
end

