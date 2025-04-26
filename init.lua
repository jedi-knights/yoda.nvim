-- Set the leader key early (before plugins/keymaps)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Boostrap the main configuration
require("yoda.config")

