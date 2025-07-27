-- lua/yoda/plugins/spec/ai.lua
-- Consolidated AI plugin specifications with DRY principles

local plugin_dev = require("yoda.utils.plugin_dev")

-- Helper function for DRY plugin configuration
local function create_plugin_spec(name, remote_spec, opts)
  opts = opts or {}
  return plugin_dev.local_or_remote_plugin(name, remote_spec, opts)
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