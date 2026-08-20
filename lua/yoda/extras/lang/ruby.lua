-- lua/yoda/extras/lang/ruby.lua
-- Opt-in Ruby stack: ruby-lsp + neotest-rspec + neotest-minitest + dap-ruby.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.ruby" }
--
-- Both test adapters are registered. neotest picks the one whose files match,
-- so a project using only RSpec simply never exercises the minitest adapter --
-- there is no need to choose up front.
require("yoda.core.lsp_registry").register({
  servers = { "ruby_lsp" },
})

--- Build and register a neotest adapter, reporting failures without
--- preventing the sibling adapter from loading.
--- @param module string adapter module name
--- @param label string human label for diagnostics
local function register_adapter(module, label)
  local ok, factory = pcall(require, module)
  if not ok then
    vim.notify(
      "[neotest] " .. module .. " not available: " .. tostring(factory),
      vim.log.levels.WARN
    )
    return
  end

  local adapter_ok, adapter = pcall(factory, {})
  if adapter_ok then
    require("yoda.core.neotest_registry").register(adapter)
  else
    vim.notify(
      "[neotest] " .. label .. " adapter setup failed: " .. tostring(adapter),
      vim.log.levels.WARN
    )
  end
end

return {
  {
    "olimorris/neotest-rspec",
    ft = "ruby",
    dependencies = { "nvim-neotest/neotest" },
    config = function()
      register_adapter("neotest-rspec", "RSpec")
    end,
  },

  {
    "zidhuss/neotest-minitest",
    ft = "ruby",
    dependencies = { "nvim-neotest/neotest" },
    config = function()
      register_adapter("neotest-minitest", "Minitest")
    end,
  },

  {
    "suketa/nvim-dap-ruby",
    ft = "ruby",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local ok, dap_ruby = pcall(require, "dap-ruby")
      if not ok then
        vim.notify(
          "[dap] nvim-dap-ruby not available: " .. tostring(dap_ruby),
          vim.log.levels.WARN
        )
        return
      end
      local setup_ok, err = pcall(dap_ruby.setup)
      if not setup_ok then
        vim.notify(
          "[dap] nvim-dap-ruby setup failed: " .. tostring(err),
          vim.log.levels.WARN
        )
      end
    end,
  },
}
