-- lua/plugins/neotest-node.lua
-- Jest + Vitest neotest adapters. Split out of testing.lua in P2. Moves to
-- extras/lang/node.lua in Phase 2 of the v1.0.0 restructure.

return {
  {
    "nvim-neotest/neotest-jest",
    ft = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
    dependencies = { "nvim-neotest/neotest" },
    config = function()
      local ok, neotest_jest = pcall(require, "neotest-jest")
      if not ok then
        vim.notify(
          "[neotest] neotest-jest not available: " .. tostring(neotest_jest),
          vim.log.levels.WARN
        )
        return
      end

      local adapter_ok, adapter = pcall(neotest_jest, {
        jestCommand = "npm test --",
        jestConfigFile = "jest.config.js",
        env = { CI = true },
        cwd = function()
          return vim.fn.getcwd()
        end,
      })
      if adapter_ok then
        require("yoda.core.neotest_registry").register(adapter)
      else
        vim.notify(
          "[neotest] Jest adapter setup failed: " .. tostring(adapter),
          vim.log.levels.WARN
        )
      end
    end,
  },

  {
    "marilari88/neotest-vitest",
    ft = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
    dependencies = { "nvim-neotest/neotest" },
    config = function()
      local ok, neotest_vitest = pcall(require, "neotest-vitest")
      if not ok then
        vim.notify(
          "[neotest] neotest-vitest not available: " .. tostring(neotest_vitest),
          vim.log.levels.WARN
        )
        return
      end
      require("yoda.core.neotest_registry").register(neotest_vitest)
    end,
  },
}
