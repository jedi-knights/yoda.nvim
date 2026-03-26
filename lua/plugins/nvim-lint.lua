-- lua/plugins/nvim-lint.lua

return {
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
}
