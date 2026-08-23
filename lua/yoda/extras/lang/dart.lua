-- lua/yoda/extras/lang/dart.lua
-- Opt-in Dart / Flutter stack: flutter-tools.nvim.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.dart" }
--
-- flutter-tools.nvim is the community-standard Neovim integration for both
-- Dart and Flutter: it owns dartls setup (filetypes, root markers, arg
-- passing), hot-reload, device selection, and DAP wiring. Registering dartls
-- separately through lsp_registry.servers would double-configure the server
-- and force Mason to fetch a Dart SDK Mason cannot keep in sync with the
-- one Flutter needs.
--
-- No separate neotest adapter: `neotest-dart` exists but ties tightly to
-- flutter test, which flutter-tools already exposes via its own commands
-- (`:FlutterRun`, `:FlutterTest`). Adding neotest on top would surface two
-- runners for the same tests.
return {
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local ok, flutter_tools = pcall(require, "flutter-tools")
      if not ok then
        vim.notify(
          "[yoda] flutter-tools not available: " .. tostring(flutter_tools),
          vim.log.levels.WARN
        )
        return
      end

      local setup_ok, err = pcall(flutter_tools.setup, {
        lsp = {
          -- Merged into the shared vim.lsp.config('*') wildcard from
          -- lua/yoda/lsp.lua; blink.cmp capabilities flow through.
          color = { enabled = false },
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
          },
        },
        debugger = {
          enabled = true,
          run_via_dap = true,
        },
        widget_guides = { enabled = true },
      })

      if not setup_ok then
        vim.notify(
          "[yoda] flutter-tools setup failed: " .. tostring(err),
          vim.log.levels.WARN
        )
      end
    end,
  },
}
