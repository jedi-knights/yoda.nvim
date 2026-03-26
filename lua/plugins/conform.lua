-- lua/plugins/conform.lua

return {
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
}
