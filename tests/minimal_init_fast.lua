-- Fast minimal init.lua for running tests
-- Optimized version that skips unnecessary plugin loading

-- Get the root directory
local root = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")

-- Add lua/ to runtimepath so tests can require modules
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:append(root .. "/lua")

-- Set up package.path to find yoda modules
package.path = package.path .. ";" .. root .. "/lua/?.lua"
package.path = package.path .. ";" .. root .. "/lua/?/init.lua"

-- Minimal Neovim settings for testing
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false

-- Disable notifications during fast tests for speed
vim.notify = function() end -- No-op notifications

-- Disable file watching and change detection
vim.opt.eventignore = "all"

-- Speed up test execution
vim.g.did_load_filetypes = 1
vim.g.did_indent_on = 1
vim.g.did_syntax_on = 1

-- Disable additional plugins that might slow down tests
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

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

-- Fast bootstrap for plenary only (if needed)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local plenary_path = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"

-- Only install if plenary is missing
if not vim.loop.fs_stat(plenary_path) then
  -- Bootstrap lazy.nvim if not present
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

  -- Install only plenary
  require("lazy").setup({
    {
      "nvim-lua/plenary.nvim",
      lazy = false,
    },
  }, {
    install = { missing = true },
    ui = { border = "rounded" },
    checker = { enabled = false }, -- Skip update checks
    change_detection = { enabled = false }, -- Skip file watching
    performance = {
      cache = { enabled = false }, -- Skip cache for faster startup
    },
  })
else
  -- Plenary already exists, just add it to runtimepath
  vim.opt.rtp:prepend(lazypath)
  vim.opt.rtp:prepend(plenary_path)
end

-- Note: vim.cmd mocking removed - was causing exit code issues in CI
