-- lua/yoda/extras/lang/kotlin.lua
-- Opt-in Kotlin stack: kotlin_language_server + kotlin-debug-adapter.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.kotlin" }
--
-- No neotest adapter: the only community adapter (neotest-kotest) has been
-- unmaintained for years and would surface stale errors on modern Kotlin
-- projects. `./gradlew test` and IDEA-run tests remain the workflow; this
-- extra provides language intelligence and debugging, not test integration.
require("yoda.core.lsp_registry").register({
  servers = { "kotlin_language_server" },
  dap_adapters = { "kotlin-debug-adapter" },
})

require("yoda.core.treesitter_registry").register({
  parsers = { "kotlin" },
})

-- ktlint doubles as formatter and linter -- same binary, different flags.
require("yoda.core.formatter_registry").register({
  formatters_by_ft = { kotlin = { "ktlint" } },
})

require("yoda.core.linter_registry").register({
  linters_by_ft = { kotlin = { "ktlint" } },
})

return {
  -- kotlin-debug-adapter is a Mason package rather than a Neovim plugin, so
  -- this entry exists only to attach the dap wiring. It carries no plugin of
  -- its own and piggybacks on nvim-dap.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    init = function()
      require("yoda.core.dap_registry").register(function(dap)
        local adapter = vim.fn.stdpath("data")
          .. "/mason/bin/kotlin-debug-adapter"
        if vim.fn.executable(adapter) == 0 then
          return
        end
        dap.adapters.kotlin = {
          type = "executable",
          command = adapter,
        }
        dap.configurations.kotlin = {
          {
            type = "kotlin",
            request = "launch",
            name = "Launch project",
            projectRoot = "${workspaceFolder}",
            mainClass = function()
              return vim.fn.input(
                "Main class (e.g. com.example.MainKt): ",
                "",
                "file"
              )
            end,
          },
        }
      end)
    end,
  },
}
