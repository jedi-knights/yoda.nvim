-- lua/yoda/extras/lang/java.lua
-- Opt-in Java stack: nvim-jdtls + neotest-java + the java-debug-adapter.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.java" }
--
-- jdtls is deliberately NOT registered for Mason installation. It needs a
-- per-project workspace directory and JVM flags Mason cannot supply, so yoda
-- expects it installed out of band (`brew install jdtls`). lua/yoda/lsp.lua
-- already owns its configuration and the :JdtlsQuiet / :JdtlsBuild commands.
require("yoda.core.lsp_registry").register({
  dap_adapters = { "java-debug-adapter" },
})

return {
  -- jdtls is driven per-buffer rather than by vim.lsp.enable: it needs a
  -- workspace path derived from the project root, so nvim-jdtls starts it.
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = { "mfussenegger/nvim-dap" },
  },

  {
    "rcasia/neotest-java",
    ft = "java",
    dependencies = { "nvim-neotest/neotest", "mfussenegger/nvim-jdtls" },
    config = function()
      local ok, neotest_java = pcall(require, "neotest-java")
      if not ok then
        vim.notify(
          "[neotest] neotest-java not available: " .. tostring(neotest_java),
          vim.log.levels.WARN
        )
        return
      end

      local adapter_ok, adapter = pcall(neotest_java, {})
      if adapter_ok then
        require("yoda.core.neotest_registry").register(adapter)
      else
        vim.notify(
          "[neotest] Java adapter setup failed: " .. tostring(adapter),
          vim.log.levels.WARN
        )
      end
    end,
  },
}
