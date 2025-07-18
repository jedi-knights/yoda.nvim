-- lua/yoda/plugins/spec/ai.lua
-- Consolidated AI plugin specifications

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

-- Conditionally add Mercury plugin for work environment
if vim.env.YODA_ENV == "work" then
  table.insert(plugins, {
    -- "TheWeatherCompany/mercury.nvim",   -- <-- Comment this out
    dir = "/Users/omar.crosby/src/github/TheWeatherCompany/mercury.nvim", -- <-- Add this
    name = "mercury.nvim", -- (optional, but recommended for clarity)
    dependencies = {
      "nvim-lua/plenary.nvim",
      "johnseth97/codex.nvim", -- optional
      "robitx/gp.nvim",       -- optional
    },
    config = function()
      require("mercury").setup()
    end,
  })
end

return plugins 