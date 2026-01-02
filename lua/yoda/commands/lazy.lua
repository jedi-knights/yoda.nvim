-- lua/yoda/commands/lazy.lua
-- Lazy.nvim plugin manager debug and management commands

local M = {}

local utils = require("yoda.commands.utils")
local get_console_logger = utils.get_console_logger

--- Setup Lazy.nvim related commands
function M.setup()
  -- Debug Lazy.nvim plugin manager
  vim.api.nvim_create_user_command("YodaDebugLazy", function()
    local logger = get_console_logger("debug")

    logger.info("=== Lazy.nvim Debug Information ===")
    logger.debug("Lazy.nvim path", { path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" })
    logger.debug("Plugin state path", { path = vim.fn.stdpath("state") .. "/lazy" })

    -- Check if Lazy.nvim is loaded
    local ok, lazy = pcall(require, "lazy")
    if ok then
      logger.info("Lazy.nvim loaded successfully")

      -- Check plugin status
      local plugins = lazy.get_plugins()
      logger.info("Total plugins", { count = #plugins })

      -- Check for problematic plugins
      for _, plugin in ipairs(plugins) do
        if plugin._.loaded and plugin._.load_error then
          logger.error("Plugin with error", { plugin = plugin.name, error = plugin._.load_error })
        end
      end
    else
      logger.error("Lazy.nvim failed to load", { error = lazy })
    end
  end, { desc = "Debug Lazy.nvim plugin manager" })

  -- Clean Lazy.nvim cache and state
  vim.api.nvim_create_user_command("YodaCleanLazy", function()
    local logger = get_console_logger("info")

    -- Clean up Lazy.nvim cache and state
    local lazy_state = vim.fn.stdpath("state") .. "/lazy"

    logger.info("Cleaning Lazy.nvim cache...")

    -- Clean readme directory
    local readme_dir = lazy_state .. "/readme"
    if vim.fn.isdirectory(readme_dir) == 1 then
      vim.fn.delete(readme_dir, "rf")
      logger.info("Cleaned readme directory", { path = readme_dir })
    end

    -- Clean lock file
    local lock_file = lazy_state .. "/lock.json"
    if vim.fn.filereadable(lock_file) == 1 then
      vim.fn.delete(lock_file)
      logger.info("Cleaned lock file", { path = lock_file })
    end

    -- Clean cache directory
    local cache_dir = lazy_state .. "/cache"
    if vim.fn.isdirectory(cache_dir) == 1 then
      vim.fn.delete(cache_dir, "rf")
      logger.info("Cleaned cache directory", { path = cache_dir })
    end

    logger.info("Lazy.nvim cache cleaned. Restart Neovim to reload plugins.")
  end, { desc = "Clean Lazy.nvim cache and state" })
end

return M
