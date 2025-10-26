-- lua/plugins/formatters/conform.lua
-- Conform.nvim - Modern formatter (rustfmt, black, ruff)

return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        rust = { "rustfmt" },
        lua = { "stylua" },
        python = { "ruff_format" },
        javascript = { "biome", "prettier" },
        javascriptreact = { "biome", "prettier" },
        typescript = { "biome", "prettier" },
        typescriptreact = { "biome", "prettier" },
        json = { "biome", "prettier" },
        jsonc = { "biome", "prettier" },
        cs = { "csharpier" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })

    vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
      local conform = require("conform")
      if conform.will_fallback_lsp() then
        vim.notify("Format on save enabled", vim.log.levels.INFO)
      else
        vim.notify("Format on save disabled", vim.log.levels.INFO)
      end
    end, { desc = "Toggle format on save" })
  end,
}
