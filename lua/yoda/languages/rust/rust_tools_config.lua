-- lua/yoda/languages/rust/rust_tools_config.lua
-- Rust-tools configuration with DAP setup

local M = {}

function M.setup()
  local rt = require("rust-tools")
  local mason_registry = require("mason-registry")

  local rust_tools_opts = {
    tools = {
      autoSetHints = true,
      inlay_hints = {
        show_parameter_hints = true,
        parameter_hints_prefix = "<- ",
        other_hints_prefix = "=> ",
        max_len_align = false,
        max_len_align_padding = 1,
        right_align = false,
        right_align_padding = 7,
      },
      hover_actions = {
        auto_focus = true,
        border = "rounded",
      },
    },
    server = {
      on_attach = function(client, bufnr)
        vim.keymap.set("n", "K", rt.hover_actions.hover_actions, {
          buffer = bufnr,
          desc = "Rust: Hover actions",
        })

        vim.keymap.set("n", "<leader>ca", rt.code_action_group.code_action_group, {
          buffer = bufnr,
          desc = "Rust: Code action group",
        })
      end,
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
          },
          procMacro = {
            enable = true,
          },
          checkOnSave = {
            command = "clippy",
          },
          diagnostics = {
            enable = true,
            experimental = {
              enable = true,
            },
          },
        },
      },
    },
  }

  local ok, is_installed = pcall(mason_registry.is_installed, "codelldb")
  if ok and is_installed then
    local success, codelldb_package = pcall(mason_registry.get_package, "codelldb")
    if success and codelldb_package then
      local install_ok, install_path = pcall(function()
        return codelldb_package:get_install_path()
      end)

      if install_ok and install_path then
        local codelldb_path = install_path .. "/extension/adapter/codelldb"
        local liblldb_path = install_path .. "/extension/lldb/lib/liblldb.dylib"

        if vim.loop.os_uname().sysname == "Linux" then
          liblldb_path = install_path .. "/extension/lldb/lib/liblldb.so"
        end

        rust_tools_opts.dap = {
          adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
        }
      else
        vim.notify("Failed to get codelldb install path. Rust debugging disabled.", vim.log.levels.WARN)
      end
    else
      vim.notify("Failed to get codelldb package from Mason registry. Rust debugging disabled.", vim.log.levels.WARN)
    end
  else
    vim.notify("codelldb not installed via Mason. Rust debugging disabled. Run :YodaRustSetup to install.", vim.log.levels.WARN)
  end

  rt.setup(rust_tools_opts)
end

return M
