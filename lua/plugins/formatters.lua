-- lua/plugins_new/formatters.lua
-- Formatting and linting plugins

return {
  -- Conform.nvim - Modern formatter
  {
    "stevearc/conform.nvim",
    -- BufWritePre fires just before the save — earlier events would load the
    -- plugin on every file open even when formatting is not needed.
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    -- vim.g.autoformat is read by format_on_save below; initialised here so
    -- it is set before the first BufWritePre fires.
    init = function()
      vim.g.autoformat = true
    end,
    opts = {
      notify_on_error = false,
      -- Wrap format_on_save in a function so the global toggle takes effect on
      -- every save rather than being captured at plugin-load time.
      format_on_save = function()
        if not vim.g.autoformat then
          return nil
        end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
      -- gofumpt -extra applies stricter formatting rules on top of gofmt
      -- (e.g. grouped import blocks, empty lines between declarations).
      formatters = { gofumpt = { prepend_args = { "-extra" } } },
      formatters_by_ft = {
        rust = { "rustfmt" },
        lua = { "stylua" },
        go = { "goimports", "gofumpt" },
        -- ruff_fix runs auto-fixable lint rules (import sorting, unused
        -- imports) first; ruff_format then applies style formatting.
        -- Running them in order means a single save fixes imports AND formats.
        python = { "ruff_fix", "ruff_format" },
        javascript = { "biome", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "prettier", stop_after_first = true },
        typescript = { "biome", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "prettier", stop_after_first = true },
        json = { "biome", "prettier", stop_after_first = true },
        jsonc = { "biome", "prettier", stop_after_first = true },
        yaml = { "yamlfmt" },
        markdown = { "prettier" },
        html = { "prettier" },
        sh = { "shfmt" },
        terraform = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" },
      },
    },
  },

  -- nvim-lint - Async linter runner
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- golangci-lint is intentionally excluded from linters_by_ft here; it
      -- runs on its own BufWritePost autocmd below because it is slow and
      -- causes cursor-move lag when triggered on InsertLeave.
      lint.linters_by_ft = {
        rust = { "clippy" },
        python = { "ruff" },
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        markdown = { "markdownlint" },
        terraform = { "tflint" },
      }

      -- Config resolution for golangci-lint:
      --   project-level (.golangci.yml walking up from cwd)
      --   > user-level (~/.config/golangci-lint/config.yml)
      --   > omit flag entirely
      -- Resolved at plugin-load time; consistent with how golangci-lint uses
      -- the working directory when invoked from the project root.
      local function build_golangci_args()
        local args = { "run" }
        local project_cfg = vim.fn.findfile(".golangci.yml", vim.fn.getcwd() .. ";")
        if project_cfg ~= "" then
          vim.list_extend(args, { "--config", vim.fn.fnamemodify(project_cfg, ":p") })
        else
          local user_cfg = vim.fn.expand("~/.config/golangci-lint/config.yml")
          if vim.fn.filereadable(user_cfg) == 1 then
            vim.list_extend(args, { "--config", user_cfg })
          end
        end
        vim.list_extend(args, {
          "--output.json.path=stdout",
          "--output.text.path=",
          "--show-stats=false",
          "--issues-exit-code=0",
          "--path-mode=abs",
          function()
            return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
          end,
        })
        return args
      end

      lint.linters.golangcilint = {
        cmd = "golangci-lint",
        stdin = false,
        append_fname = false,
        args = build_golangci_args(),
        stream = "stdout",
        ignore_exitcode = true,
        parser = require("lint.linters.golangcilint").parser,
      }

      -- Lint only on save — InsertLeave would spawn linters on every <Esc>,
      -- causing noticeable lag for slow linters (clippy, biome).
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("YodaLint", { clear = true }),
        callback = function()
          if vim.opt_local.modifiable:get() then
            lint.try_lint()
          end
        end,
      })

      -- golangci-lint is slow; a separate autocmd keeps it out of the general
      -- lint trigger above so other filetypes are not affected by its latency.
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("YodaLintGo", { clear = true }),
        pattern = "*.go",
        callback = function()
          lint.try_lint("golangcilint")
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
        ensure_installed = { "codelldb", "debugpy", "js-debug-adapter" },
        automatic_installation = true,
        handlers = {},
      })
    end,
  },
}
