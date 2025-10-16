-- Ultra-minimal init for fastest possible test execution
-- Skips ALL plugin loading and uses only what's absolutely necessary

-- Prevent loading of user config
vim.env.NVIM_APPNAME = "nvim-test"

-- Get the root directory
local root = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")

-- Add lua/ to runtimepath so tests can require modules
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:append(root .. "/lua")

-- Set up package.path to find yoda modules
package.path = package.path .. ";" .. root .. "/lua/?.lua"
package.path = package.path .. ";" .. root .. "/lua/?/init.lua"

-- Absolute minimal Neovim settings
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false
vim.opt.shadafile = "NONE"
vim.opt.loadplugins = false

-- Disable autocommands during startup
vim.api.nvim_create_augroup("disable_all", { clear = true })

-- Disable ALL plugins and features we don't need
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
vim.g.loaded_netrwFileHandlers = 1

-- Try to load plenary directly without lazy.nvim
local plenary_path = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"
if vim.fn.isdirectory(plenary_path) == 1 then
  vim.opt.rtp:prepend(plenary_path)
else
  -- Fallback: try to install plenary directly
  local handle = io.popen("git clone --depth 1 https://github.com/nvim-lua/plenary.nvim " .. plenary_path .. " 2>/dev/null")
  if handle then
    handle:close()
    vim.opt.rtp:prepend(plenary_path)
  end
end
