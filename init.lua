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

local ks = require('keystroke_logger')

vim.keymap.set('n', '<leader>ks', ks.start, { desc = 'Start keystroke logging' })
vim.keymap.set('n', '<leader>ke', ks.stop, { desc = 'Stop keystroke logging' })

