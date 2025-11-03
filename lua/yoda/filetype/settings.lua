-- lua/yoda/filetype/settings.lua
-- Filetype-specific settings and performance profiles

local M = {}

-- ============================================================================
-- Dependencies
-- ============================================================================

local alpha_manager = require("yoda.ui.alpha_manager")

-- ============================================================================
-- Performance Profiles
-- ============================================================================

local PERFORMANCE_PROFILES = {
  aggressive = function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.updatetime = 4000
    vim.opt_local.timeoutlen = 1000
    vim.opt_local.ttimeoutlen = 0
    vim.opt_local.lazyredraw = true
    vim.opt_local.synmaxcol = 200
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
    vim.opt_local.relativenumber = false
  end,

  commit = function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.updatetime = 2000
    vim.opt_local.lazyredraw = true
    vim.opt_local.synmaxcol = 200
    vim.opt_local.timeoutlen = 1000
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
    vim.opt_local.relativenumber = false
    vim.opt_local.complete = ""
    vim.opt_local.completeopt = ""
  end,

  neogit = function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.updatetime = 2000
    vim.opt_local.lazyredraw = true
    vim.opt_local.cursorline = false
    vim.opt_local.synmaxcol = 200
  end,
}

-- ============================================================================
-- Filetype-specific Settings
-- ============================================================================

local FILETYPE_SETTINGS = {
  markdown = function()
    PERFORMANCE_PROFILES.aggressive()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
    vim.opt_local.conceallevel = 0
    vim.opt_local.number = false
    vim.opt_local.colorcolumn = ""
  end,

  gitcommit = function()
    PERFORMANCE_PROFILES.commit()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.textwidth = 72
  end,

  NeogitCommitMessage = function()
    PERFORMANCE_PROFILES.commit()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.textwidth = 72
  end,

  NeogitStatus = function()
    PERFORMANCE_PROFILES.neogit()
  end,

  NeogitPopup = function()
    PERFORMANCE_PROFILES.neogit()
  end,

  ["snacks-explorer"] = function()
    vim.cmd("stopinsert")
    vim.schedule(function()
      if vim.fn.mode() ~= "n" then
        vim.cmd("stopinsert")
      end

      -- Recenter alpha dashboard if it's open
      alpha_manager.recenter_alpha_dashboard()
    end)
  end,

  -- Helm template files: use YAML syntax with helm-specific settings
  helm = function()
    vim.opt_local.commentstring = "# %s"
    vim.opt_local.syntax = "yaml" -- Use YAML syntax highlighting as base
    vim.opt_local.wrap = false
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,

  -- Regular YAML files
  yaml = function()
    vim.opt_local.commentstring = "# %s"
    vim.opt_local.wrap = false
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,

  -- Groovy files (including Jenkinsfiles)
  groovy = function()
    vim.opt_local.commentstring = "// %s"
    vim.opt_local.wrap = false
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    -- Enable syntax highlighting
    vim.opt_local.syntax = "groovy"
  end,

  -- Properties files (disable treesitter, use simple syntax)
  properties = function()
    vim.opt_local.commentstring = "# %s"
    vim.opt_local.wrap = false
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    -- Disable treesitter explicitly to prevent temp file errors
    vim.b.ts_highlight = false
    -- Use basic syntax highlighting
    vim.opt_local.syntax = "conf"
  end,
}

-- ============================================================================
-- Public API
-- ============================================================================

--- Apply filetype-specific settings
--- @param filetype string The filetype to configure
function M.apply(filetype)
  if type(filetype) ~= "string" or filetype == "" then
    return
  end

  local settings_fn = FILETYPE_SETTINGS[filetype]
  if settings_fn then
    settings_fn()
  end
end

--- Check if filetype has custom settings
--- @param filetype string The filetype to check
--- @return boolean
function M.has_settings(filetype)
  return FILETYPE_SETTINGS[filetype] ~= nil
end

--- Get list of supported filetypes
--- @return table
function M.get_supported_filetypes()
  local filetypes = {}
  for ft, _ in pairs(FILETYPE_SETTINGS) do
    table.insert(filetypes, ft)
  end
  table.sort(filetypes)
  return filetypes
end

return M
