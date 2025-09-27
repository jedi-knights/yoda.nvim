-- lua/yoda/plugins/spec/ai.lua
-- Consolidated AI plugin specifications with DRY principles
-- Cursor-like agentic AI workflow with Avante.nvim and claudecode.nvim
--
-- TEST PLAN:
-- 1) Install Claude Code CLI and authenticate:
--    npm i -g @anthropic-ai/claude-code
--    claude doctor && claude auth status
-- 2) In Neovim:
--    :Lazy sync
--    :AIHealth → should show green checks or clear guidance
-- 3) Test Avante workflow:
--    Open code file, select function in visual mode
--    <leader>as to send to Avante, ask to refactor
--    Expect patch view, then <leader>ay to accept
-- 4) Test claudecode fallback:
--    <leader>ac then visual select → <leader>aS
--    Accept/reject diff with <leader>aY / <leader>aN

local plugin_dev = require("yoda.utils.plugin_dev")

-- Helper function for DRY plugin configuration
local function create_plugin_spec(name, remote_spec, opts)
  opts = opts or {}
  return plugin_dev.local_or_remote_plugin(name, remote_spec, opts)
end

-- Claude CLI path helper
local function get_claude_path()
  local ok, claude_path = pcall(require, "yoda.ai.claude_path")
  if ok and claude_path then
    return claude_path.get()
  end
  return nil
end

-- Base AI plugin configurations
local ai_plugins = {
  -- GitHub Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
          },
          layout = {
            position = "bottom",
            ratio = 0.4
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          [".*"] = false,
        },
        copilot_node_command = 'node',
        server_opts_overrides = {},
      })
    end,
  },

  -- MCP Hub for Model Context Protocol
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest",
    config = function()
      require("mcphub").setup()
    end,
  },

  -- Avante.nvim - Primary agentic AI workflow (Cursor-like)
  {
    "yetone/avante.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/snacks.nvim",
    },
    cmd = { "AvanteAsk", "AvanteChat", "AvanteMCP" },
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "Ask Avante AI" },
      { "<leader>ac", "<cmd>AvanteChat<cr>", desc = "Open Avante Chat" },
      { "<leader>am", "<cmd>AvanteMCP<cr>", desc = "Open MCP Hub" },
    },
    config = function()
      require("avante").setup({
        provider = "claude-code",
        -- Auto-discover Claude CLI path
        claude_path = get_claude_path(),
        -- UI configuration
        ui = {
          border = "rounded",
          width = 0.8,
          height = 0.8,
          position = "center",
        },
        -- Context files to include
        context_files = {
          "CLAUDE.md",
          ".claude.md",
          "claude.md",
        },
      })
      
      -- Setup AI keymaps
      local ok, ai_mappings = pcall(require, "yoda.ai.mappings")
      if ok and ai_mappings then
        ai_mappings.setup_avante()
      end
      
      -- Setup AI health commands
      local ok_health, ai_health = pcall(require, "yoda.ai.health")
      if ok_health and ai_health then
        ai_health.setup_commands()
      end
    end,
  },

  -- claudecode.nvim - Secondary native protocol option
  {
    "coder/claudecode.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = { "ClaudeCode", "ClaudeCodeSend", "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny" },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Launch ClaudeCode" },
      { "<leader>aS", ":ClaudeCodeSend<cr>", desc = "Send selection to ClaudeCode", mode = "v" },
      { "<leader>aY", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept ClaudeCode diff" },
      { "<leader>aN", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject ClaudeCode diff" },
    },
    config = function()
      local claude_path = get_claude_path()
      
      require("claudecode").setup({
        terminal_cmd = claude_path,
        -- Show warning if Claude CLI not found
        on_init = function()
          if not claude_path then
            vim.notify_once(
              "Claude CLI not found. Run: npm i -g @anthropic-ai/claude-code && claude auth",
              vim.log.levels.WARN,
              { title = "ClaudeCode Setup" }
            )
          end
        end,
      })
      
      -- Setup AI keymaps
      local ok, ai_mappings = pcall(require, "yoda.ai.mappings")
      if ok and ai_mappings then
        ai_mappings.setup_claudecode()
      end
      
      -- Setup AI health commands (only once)
      local ok_health, ai_health = pcall(require, "yoda.ai.health")
      if ok_health and ai_health and not _G.ai_commands_setup then
        ai_health.setup_commands()
        _G.ai_commands_setup = true
      end
    end,
  },

  -- Snacks.nvim - For neat terminal/floats
  {
    "folke/snacks.nvim",
    config = function()
      require("snacks").setup()
    end,
  },
}

-- Environment-specific AI plugins
local function get_environment_plugins()
  local env_plugins = {}
  
  -- Mercury plugin (work environment only)
  if vim.env.YODA_ENV == "work" then
    local mercury_spec = create_plugin_spec("mercury", "TheWeatherCompany/mercury.nvim", {
      dependencies = {
        "nvim-lua/plenary.nvim",
        "johnseth97/codex.nvim",
        "robitx/gp.nvim",
      },
      config = function()
        require("mercury").setup()
      end,
    })
    
    if mercury_spec then
      table.insert(env_plugins, mercury_spec)
    end
  end
  
  return env_plugins
end

-- Combine base and environment-specific plugins
local function get_all_ai_plugins()
  local all_plugins = vim.list_extend({}, ai_plugins)
  local env_plugins = get_environment_plugins()
  vim.list_extend(all_plugins, env_plugins)
  return all_plugins
end

return get_all_ai_plugins() 