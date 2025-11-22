-- lua/plugins_new/ai.lua
-- AI integration plugins

return {
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
            open = "<M-CR>",
          },
          layout = {
            position = "bottom",
            ratio = 0.4,
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = false,
          debounce = 75,
          keymap = {
            accept = false, -- Disable built-in, we use custom keymaps
            accept_word = false,
            accept_line = false,
            next = false, -- Disable built-in, we use custom keymaps
            prev = false, -- Disable built-in, we use custom keymaps
            dismiss = false, -- Disable built-in, we use custom keymaps
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
          ["."] = false,
          NeogitCommitMessage = false,
          NeogitStatus = false,
          NeogitPopup = false,
        },
        copilot_node_command = "node",
        server_opts_overrides = {},
      })
    end,
  },

  -- OpenCode - AI assistant integration
  {
    "NickvanDyke/opencode.nvim",
    lazy = false,
    dependencies = {
      "folke/snacks.nvim", -- Required for toggle functionality
    },
    config = function()
      vim.g.opencode_opts = {
        -- Auto-reload buffers edited by opencode
        auto_reload = true,

        -- Window configuration
        window = {
          width = 0.4, -- 40% of screen width
          height = 0.8, -- 80% of screen height
          position = "right", -- "left", "right", "top", "bottom"
        },

        -- Default provider and model
        -- provider = "anthropic",
        -- model = "claude-3-5-sonnet-20241022",

        -- Custom prompts
        prompts = {
          explain = "Explain @thisnd its context in detail",
          optimize = "Suggest optimizations for @this",
          test = "Write comprehensive tests for @this",
        },
      }

      -- Required for enhanced buffer management
      vim.opt.autoread = true
      vim.opt.autowrite = true -- Auto-write buffers when switching

      -- Setup OpenCode integration
      local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
      if ok then
        vim.defer_fn(function()
          opencode_integration.setup()
        end, 100)
      end
    end,
  },
}
