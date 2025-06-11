-- Set the leader key early (before plugins/keymaps)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.dbs = {
  gid = "postgresql://sun_qa@gid-qa.cvxyfczr5mcu.us-east-1.rds.amazonaws.com:8080/gid"
}

-- Boostrap the main configuration
require("yoda")

-- Define a function to print and return a value
function _G.P(v)
  print(vim.inspect(v))
  return v
end

