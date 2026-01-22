-- lua/yoda/autocmds/focus.lua
-- Centralized FocusGained handler to coordinate all refresh operations

local M = {}

local gitsigns = require("yoda.integrations.gitsigns")
local buffer_state = require("yoda.buffer.state_checker")

-- ============================================================================
-- Configuration
-- ============================================================================

local FOCUS_CONFIG = {
  DEBOUNCE_MS = 100, -- Debounce to prevent multiple rapid focus events
}

-- ============================================================================
-- Private State
-- ============================================================================

local last_focus_time = 0
local timer_manager = nil

-- Lazy load timer_manager
local function get_timer_manager()
  if not timer_manager then
    local ok, tm = pcall(require, "yoda.timer_manager")
    if ok then
      timer_manager = tm
    end
  end
  return timer_manager
end

-- ============================================================================
-- Refresh Coordinators
-- ============================================================================

--- Coordinate all refresh operations when focus is gained
--- @param logger table|nil Optional logger
local function coordinate_refresh(logger)
  local current_time = vim.loop.hrtime() / 1000000

  -- Debounce rapid focus events
  if (current_time - last_focus_time) < FOCUS_CONFIG.DEBOUNCE_MS then
    if logger then
      logger.log("Focus_Debounce_Skip", {
        elapsed = current_time - last_focus_time,
        threshold = FOCUS_CONFIG.DEBOUNCE_MS,
      })
    end
    return
  end

  last_focus_time = current_time

  if logger then
    logger.log("Focus_Refresh_Start", { time = current_time })
  end

  -- Skip if in opencode buffer
  local current_ft = vim.bo.filetype
  if current_ft == "opencode" then
    if logger then
      logger.log("Focus_Skip", { reason = "opencode_buffer" })
    end
    return
  end

  vim.schedule(function()
    -- 1. Check for external file changes
    pcall(vim.cmd, "checktime")

    -- 2. Refresh current buffer if reloadable
    if buffer_state.can_reload_buffer() and vim.fn.filereadable(vim.fn.expand("%")) == 1 then
      local current_buf = vim.api.nvim_get_current_buf()
      if logger then
        logger.log("Focus_Refresh_Buffer", { buf = current_buf })
      end

      local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
      if ok and opencode_integration.refresh_buffer then
        opencode_integration.refresh_buffer(current_buf)
      end
    end

    -- 3. Refresh git signs (batched)
    if logger then
      logger.log("Focus_Refresh_GitSigns", {})
    end
    gitsigns.refresh_batched()
  end)

  if logger then
    logger.log("Focus_Refresh_Complete", { time = vim.loop.hrtime() / 1000000 })
  end
end

-- ============================================================================
-- Public API
-- ============================================================================

--- Setup consolidated FocusGained handler
--- @param autocmd function Autocmd creation function
--- @param augroup function Augroup creation function
function M.setup_all(autocmd, augroup)
  local autocmd_logger_ok, autocmd_logger = pcall(require, "yoda.autocmd_logger")
  local logger = autocmd_logger_ok and autocmd_logger or nil

  autocmd("FocusGained", {
    group = augroup("YodaConsolidatedFocusRefresh", { clear = true }),
    desc = "Consolidated handler for focus refresh - coordinates buffer reload and git signs",
    callback = function()
      coordinate_refresh(logger)
    end,
  })

  if logger then
    logger.log("Focus_Handler_Setup", { debounce_ms = FOCUS_CONFIG.DEBOUNCE_MS })
  end
end

--- Get focus handler state (for testing/debugging)
--- @return table state Focus handler state
function M.get_state()
  return {
    last_focus_time = last_focus_time,
    debounce_ms = FOCUS_CONFIG.DEBOUNCE_MS,
  }
end

--- Reset focus handler state (for testing)
function M.reset_state()
  last_focus_time = 0
end

return M
