-- lua/plugins/formatters/lint.lua
-- nvim-lint - Modern linter (Clippy, ruff, mypy)

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      rust = { "clippy" },
      python = { "ruff" },
      javascript = { "biome" },
      javascriptreact = { "biome" },
      typescript = { "biome" },
      typescriptreact = { "biome" },
    }

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      callback = function()
        local linters = lint.linters_by_ft[vim.bo.filetype]
        if linters then
          lint.try_lint()
        end
      end,
    })
  end,
}
