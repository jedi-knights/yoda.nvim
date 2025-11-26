-- lua/plugins_new/formatters.lua
-- Formatting and linting plugins

return {
  -- Conform.nvim - Modern formatter (rustfmt, black, ruff)
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          rust = { "rustfmt" },
          lua = { "stylua" },
          python = { "ruff_format" }, -- Ruff handles formatting, linting, and import sorting
          javascript = { "biome", "prettier" }, -- Try biome first, fallback to prettier
          javascriptreact = { "biome", "prettier" },
          typescript = { "biome", "prettier" },
          typescriptreact = { "biome", "prettier" },
          json = { "biome", "prettier" },
          jsonc = { "biome", "prettier" },
          cs = { "csharpier" }, -- C# formatter
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      -- Add command to toggle format on save
      vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
        local conform = require("conform")
        if conform.will_fallback_lsp() then
          vim.notify("Format on save enabled", vim.log.levels.INFO)
        else
          vim.notify("Format on save disabled", vim.log.levels.INFO)
        end
      end, { desc = "Toggle format on save" })
    end,
  },

  -- nvim-lint - Modern linter (Clippy, ruff, mypy)
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- Configure linters by filetype
      lint.linters_by_ft = {
        rust = { "clippy" },
        python = { "ruff" }, -- Ruff handles linting, formatting, import sorting, and basic type checking
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
      }

      -- Auto-lint on certain events (removed BufEnter for performance)
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function()
          -- Only lint if linters are configured
          local linters = lint.linters_by_ft[vim.bo.filetype]
          if linters then
            -- Check if at least one linter is available before trying to lint
            local has_available_linter = false
            for _, linter_name in ipairs(linters) do
              local linter = lint.linters[linter_name]
              if linter then
                -- Check if linter executable exists
                local cmd = linter.cmd
                if type(cmd) == "function" then
                  cmd = cmd()
                end
                if cmd and vim.fn.executable(cmd) == 1 then
                  has_available_linter = true
                  break
                end
              end
            end

            if has_available_linter then
              lint.try_lint()
            end
          end
        end,
      })
    end,
  },

  -- Overseer.nvim - Task runner for cargo commands
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerInfo", "OverseerBuild" },
    config = function()
      require("overseer").setup({
        templates = { "builtin" },
        task_list = {
          direction = "bottom",
          min_height = 25,
          max_height = 25,
          default_detail = 1,
          bindings = {
            ["?"] = "ShowHelp",
            ["g?"] = "ShowHelp",
            ["<CR>"] = "RunAction",
            ["<C-e>"] = "Edit",
            ["o"] = "Open",
            ["<C-v>"] = "OpenVsplit",
            ["<C-s>"] = "OpenSplit",
            ["<C-f>"] = "OpenFloat",
            ["<C-q>"] = "OpenQuickFix",
            ["p"] = "TogglePreview",
            ["<C-l>"] = "IncreaseDetail",
            ["<C-h>"] = "DecreaseDetail",
            ["L"] = "IncreaseAllDetail",
            ["H"] = "DecreaseAllDetail",
            ["["] = "DecreaseWidth",
            ["]"] = "IncreaseWidth",
            ["{"] = "PrevTask",
            ["}"] = "NextTask",
            ["<C-k>"] = "ScrollOutputUp",
            ["<C-j>"] = "ScrollOutputDown",
          },
        },
      })
    end,
  },

  -- Mason-nvim-dap - Auto-install DAP adapters via Mason
  {
    "jay-babu/mason-nvim-dap.nvim",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "debugpy", "js-debug-adapter", "netcoredbg" },
        automatic_installation = true,
        handlers = {},
      })
    end,
  },
}
