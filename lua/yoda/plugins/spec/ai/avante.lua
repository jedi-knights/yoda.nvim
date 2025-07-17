return {
  'yetone/avante.nvim',
  build = function()
    -- conditionally use the correct build system for the current OS
    if vim.fn.has 'win32' == 1 then
      return 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false'
    else
      return 'make'
    end
  end,
  event = 'VeryLazy',
  version = false, -- Never set this value to "*"! Never!
  ---@module 'avante'
  ---@type avante.Config
  opts = {},
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    'echasnovski/mini.pick', -- for file_selector provider mini.pick
    'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
    'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    'ibhagwan/fzf-lua', -- for file_selector provider fzf
    'stevearc/dressing.nvim', -- for input provider dressing
    'folke/snacks.nvim', -- for input provider snacks
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    'zbirenbaum/copilot.lua', -- for providers='copilot'
    {
      -- support for image pasting
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
  config = function()
    local env = os.getenv("YODA_ENV")
    local is_work = env == "work"

    local provider, provider_config
    if is_work then
      provider = "openai"
      provider_config = {
        openai = {
          endpoint = os.getenv("OPENAI_API_BASE"),
          model = os.getenv("OPENAI_API_MODEL"),
          api_key_name = os.getenv("OPENAI_API_KEY_NAME") or "OPENAI_API_KEY",
          timeout = 30000,
          extra_request_body = {
            temperature = tonumber(os.getenv("OPENAI_API_TEMPERATURE")) or 0.75,
            max_tokens = tonumber(os.getenv("OPENAI_API_MAX_TOKENS")) or 20480,
          },
        }
      }
    else
      provider = "claude"
      provider_config = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-3-opus-20240229", -- or your preferred Claude model
          api_key_name = "CLAUDE_API_KEY",
          timeout = 30000,
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 20480,
          },
        }
      }
    end

    require("avante").setup({
      provider = provider,
      providers = provider_config,
      system_prompt = function()
        local hub = require('mcphub').get_hub_instance()
        return hub and hub:get_active_servers_prompt() or ''
      end,
      custom_tools = function()
        return {
          require('mcphub.extensions.avante').mcp_tool(),
        }
      end,
    })
  end,
} 