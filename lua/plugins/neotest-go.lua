-- lua/plugins/neotest-go.lua
-- Go neotest adapter. Split out of testing.lua in P2. Moves to
-- extras/lang/go.lua in Phase 2 of the v1.0.0 restructure.

return {
  {
    "fredrikaverpil/neotest-golang",
    ft = "go",
    dependencies = { "nvim-neotest/neotest" },
    config = function()
      local ok, neotest_golang = pcall(require, "neotest-golang")
      if not ok then
        vim.notify(
          "[neotest] neotest-golang not available: " .. tostring(neotest_golang),
          vim.log.levels.WARN
        )
        return
      end

      local adapter_ok, adapter = pcall(neotest_golang, {})
      if adapter_ok then
        require("yoda.core.neotest_registry").register(adapter)
      else
        vim.notify(
          "[neotest] Go adapter setup failed: " .. tostring(adapter),
          vim.log.levels.WARN
        )
      end
    end,
  },
}
