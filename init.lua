-- Set the leader key early (before plugins/keymaps)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Boostrap the main configuration
require("yoda.config")

-- Define a function to print and return a value
function _G.P(v)
  print(vim.inspect(v))
  return v
end

