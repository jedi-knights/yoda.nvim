-- lua/yoda/ai/mappings.lua
-- AI agentic workflow keymaps for Cursor-like experience
-- Extends existing <leader>a* mappings with new agentic capabilities

local M = {}

-- Check if a keymap is already bound to avoid conflicts
local function is_keymap_available(mode, key)
  local ok, result = pcall(vim.keymap.get, mode, key)
  return not ok or not result
end

-- Register keymaps with conflict detection
local function safe_keymap_set(mode, key, rhs, opts)
  if not is_keymap_available(mode, key) then
    vim.notify_once(
      string.format("Keymap <%s> already bound, skipping AI mapping", key),
      vim.log.levels.WARN,
      { title = "AI Keymaps" }
    )
    return false
  end
  
  vim.keymap.set(mode, key, rhs, opts)
  return true
end

-- Setup which-key group for AI mappings
local function setup_which_key_group()
  local ok, wk = pcall(require, "which-key")
  if ok and wk then
    wk.register({
      a = {
        name = "AI / Claude",
      },
    }, { prefix = "<leader>" })
  end
end

-- Avante.nvim keymaps (primary agentic workflow)
function M.setup_avante()
  -- Core Avante commands (these already exist in keymaps.lua, so we extend them)
  local avante_keymaps = {
    -- Agentic workflow keymaps
    ["<leader>as"] = {
      function()
        -- Send visual selection to Avante
        local ok, avante = pcall(require, "avante")
        if ok and avante then
          avante.ask_selection()
        else
          vim.notify("Avante not available", vim.log.levels.ERROR)
        end
      end,
      { desc = "Send selection to Avante", mode = "v" }
    },
    
    ["<leader>ax"] = {
      function()
        -- Close/stop Avante session
        local ok, avante = pcall(require, "avante")
        if ok and avante and avante.close then
          avante.close()
        else
          vim.cmd("AvanteClose")
        end
      end,
      { desc = "Close Avante session" }
    },
    
    ["<leader>ad"] = {
      function()
        -- Show pending diff/patch
        local ok, avante = pcall(require, "avante")
        if ok and avante and avante.show_diff then
          avante.show_diff()
        else
          vim.cmd("AvanteDiff")
        end
      end,
      { desc = "Show pending diff" }
    },
    
    ["<leader>ay"] = {
      function()
        -- Accept patch
        local ok, avante = pcall(require, "avante")
        if ok and avante and avante.accept_diff then
          avante.accept_diff()
        else
          vim.cmd("AvanteAccept")
        end
      end,
      { desc = "Accept AI patch" }
    },
    
    ["<leader>an"] = {
      function()
        -- Reject patch
        local ok, avante = pcall(require, "avante")
        if ok and avante and avante.reject_diff then
          avante.reject_diff()
        else
          vim.cmd("AvanteReject")
        end
      end,
      { desc = "Reject AI patch" }
    },
    
    ["<leader>am"] = {
      function()
        -- Model selection (if exposed by Avante)
        local ok, avante = pcall(require, "avante")
        if ok and avante and avante.select_model then
          avante.select_model()
        else
          vim.cmd("AvanteModel")
        end
      end,
      { desc = "Select AI model" }
    },
  }
  
  -- Register Avante keymaps
  for key, config in pairs(avante_keymaps) do
    local rhs = config[1]
    local opts = config[2] or {}
    safe_keymap_set(opts.mode or "n", key, rhs, opts)
  end
end

-- claudecode.nvim keymaps (secondary native protocol)
function M.setup_claudecode()
  local claudecode_keymaps = {
    -- These are already defined in the plugin spec, but we can add extras here
    ["<leader>aR"] = {
      function()
        -- Restart ClaudeCode session
        vim.cmd("ClaudeCodeRestart")
      end,
      { desc = "Restart ClaudeCode" }
    },
    
    ["<leader>aC"] = {
      function()
        -- Clear ClaudeCode context
        vim.cmd("ClaudeCodeClear")
      end,
      { desc = "Clear ClaudeCode context" }
    },
  }
  
  -- Register claudecode keymaps
  for key, config in pairs(claudecode_keymaps) do
    local rhs = config[1]
    local opts = config[2] or {}
    safe_keymap_set(opts.mode or "n", key, rhs, opts)
  end
end

-- Setup all AI mappings
function M.setup()
  -- Setup which-key group
  setup_which_key_group()
  
  -- Setup plugin-specific keymaps
  M.setup_avante()
  M.setup_claudecode()
  
  vim.notify("AI keymaps loaded successfully", vim.log.levels.INFO)
end

return M
