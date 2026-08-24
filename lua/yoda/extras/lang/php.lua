-- lua/yoda/extras/lang/php.lua
-- Opt-in PHP stack: intelephense + neotest-phpunit + php-debug-adapter.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.php" }
--
-- intelephense's free tier covers completion, hover, diagnostics, and
-- navigation for most projects; upgrading unlocks rename, code actions and
-- deep index features. Debugging requires Xdebug configured on the PHP
-- runtime (default listener port 9003 as of Xdebug 3).
require("yoda.core.lsp_registry").register({
  servers = { "intelephense" },
  dap_adapters = { "php-debug-adapter" },
})

require("yoda.core.treesitter_registry").register({
  parsers = { "php", "phpdoc" },
})

require("yoda.core.formatter_registry").register({
  formatters_by_ft = { php = { "php_cs_fixer" } },
})

require("yoda.core.linter_registry").register({
  linters_by_ft = { php = { "phpcs" } },
})

return {
  {
    "olimorris/neotest-phpunit",
    ft = "php",
    dependencies = { "nvim-neotest/neotest" },
    config = function()
      local ok, neotest_phpunit = pcall(require, "neotest-phpunit")
      if not ok then
        vim.notify(
          "[neotest] neotest-phpunit not available: "
            .. tostring(neotest_phpunit),
          vim.log.levels.WARN
        )
        return
      end

      local adapter_ok, adapter = pcall(neotest_phpunit, {})
      if adapter_ok then
        require("yoda.core.neotest_registry").register(adapter)
      else
        vim.notify(
          "[neotest] PHPUnit adapter setup failed: " .. tostring(adapter),
          vim.log.levels.WARN
        )
      end
    end,
  },

  -- php-debug-adapter is a Mason package rather than a Neovim plugin, so this
  -- entry exists only to attach the dap wiring. It carries no plugin of its
  -- own and piggybacks on nvim-dap.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    init = function()
      require("yoda.core.dap_registry").register(function(dap)
        local adapter = vim.fn.stdpath("data") .. "/mason/bin/php-debug-adapter"
        if vim.fn.executable(adapter) == 0 then
          return
        end
        dap.adapters.php = {
          type = "executable",
          command = adapter,
        }
        dap.configurations.php = {
          {
            type = "php",
            request = "launch",
            name = "Listen for Xdebug",
            -- Xdebug 3 default; override in .vscode/launch.json for legacy
            -- Xdebug 2 setups still on 9000.
            port = 9003,
          },
        }
      end)
    end,
  },
}
