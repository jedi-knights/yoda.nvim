-- lua/yoda/extras/lang/perl.lua
-- Opt-in Perl stack: PerlNavigator + the Perl debug adapter.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.perl" }
--
-- No neotest adapter: none exists for Perl's test frameworks (Test::More,
-- prove) at the time of writing. `:!prove` remains the workflow; this extra
-- provides language intelligence and debugging, not test integration.
require("yoda.core.lsp_registry").register({
  servers = { "perlnavigator" },
  dap_adapters = { "perl-debug-adapter" },
})

return {
  -- The debug adapter is a Mason package rather than a Neovim plugin, so this
  -- entry exists only to attach the dap wiring. It carries no plugin of its
  -- own and piggybacks on nvim-dap.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    init = function()
      require("yoda.core.dap_registry").register(function(dap)
        local adapter = vim.fn.stdpath("data")
          .. "/mason/bin/perl-debug-adapter"
        if vim.fn.executable(adapter) == 0 then
          return
        end
        dap.adapters.perlsplit = {
          type = "executable",
          command = adapter,
        }
        dap.configurations.perl = {
          {
            type = "perlsplit",
            request = "launch",
            name = "Launch current file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
        }
      end)
    end,
  },
}
