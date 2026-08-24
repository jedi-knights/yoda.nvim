-- lua/yoda/extras/lang/clang.lua
-- Opt-in C / C++ stack: clangd LSP + codelldb DAP wiring.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.clang" }
--
-- One extra for both languages because clangd is a single binary that serves
-- c, cpp, objc, and objcpp indistinguishably, and codelldb debugs any binary
-- clang or gcc produced. Splitting them would just mean two files that
-- register the same server and the same adapter.
--
-- codelldb is deliberately NOT registered via lsp_registry.dap_adapters:
-- lua/yoda/plugins/mason.lua already ships it in mason-nvim-dap's core
-- ensure_installed, so re-registration would add a duplicate entry.
require("yoda.core.lsp_registry").register({
  servers = { "clangd" },
})

require("yoda.core.treesitter_registry").register({
  parsers = { "c", "cpp" },
})

-- clang-format serves both C and C++ (it dispatches on file extension).
require("yoda.core.formatter_registry").register({
  formatters_by_ft = {
    c = { "clang-format" },
    cpp = { "clang-format" },
  },
})

-- clangtidy is the nvim-lint identifier; the underlying binary is clang-tidy.
require("yoda.core.linter_registry").register({
  linters_by_ft = {
    c = { "clangtidy" },
    cpp = { "clangtidy" },
  },
})

return {
  -- codelldb is installed via the core mason-nvim-dap ensure_installed; wire
  -- it into nvim-dap. Registered through dap_registry rather than by
  -- re-declaring the nvim-dap spec, whose `config` lazy.nvim would replace
  -- rather than merge.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    init = function()
      require("yoda.core.dap_registry").register(function(dap)
        local mason = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
        if vim.fn.executable(mason) == 0 then
          return
        end
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = {
            command = mason,
            args = { "--port", "${port}" },
          },
        }
        for _, ft in ipairs({ "c", "cpp" }) do
          dap.configurations[ft] = {
            {
              type = "codelldb",
              name = "Launch file",
              request = "launch",
              program = function()
                return vim.fn.input(
                  "Path to executable: ",
                  vim.fn.getcwd() .. "/",
                  "file"
                )
              end,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
            },
          }
        end
      end)
    end,
  },
}
