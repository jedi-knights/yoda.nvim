-- lua/yoda/plugins/spec/ai.lua
-- Consolidated AI plugin specifications

local plugin_dev = require("yoda.utils.plugin_dev")

local plugins = {
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
            position = "bottom", -- | top | left | right
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
        copilot_node_command = 'node', -- Node.js version must be > 18.x
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
    build = "npm install -g mcp-hub@latest",  -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup()
    end,
  },
}

-- Only add Mercury plugin if YODA_ENV == 'work'
if vim.env.YODA_ENV == "work" then
  local mercury_opts = {
    dependencies = {
      "nvim-lua/plenary.nvim",
      "johnseth97/codex.nvim", -- optional
      "robitx/gp.nvim",       -- optional
    },
    config = function()
      require("mercury").setup()
    end,
  }

  local mercury_plugin = plugin_dev.local_or_remote_plugin(
    "mercury",
    "TheWeatherCompany/mercury.nvim",
    mercury_opts
  )

  if mercury_plugin then
    table.insert(plugins, mercury_plugin)
  end
end

return plugins 