-- lua/plugins/ai/opencode.lua
-- OpenCode - AI assistant integration

return {
  "NickvanDyke/opencode.nvim",
  lazy = true,
  cmd = { "OpencodePrompt", "OpencodeAsk", "OpencodeSelect", "OpencodeToggle" },
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    vim.g.opencode_opts = {
      auto_reload = true,
      window = {
        width = 0.4,
        height = 0.8,
        position = "right",
      },
      prompts = {
        explain = "Explain @this and its context in detail",
        optimize = "Suggest optimizations for @this",
        test = "Write comprehensive tests for @this",
      },
    }

    vim.opt.autoread = true
    vim.opt.autowrite = true

    local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
    if ok then
      vim.defer_fn(function()
        opencode_integration.setup()
      end, 100)
    end
  end,
}
