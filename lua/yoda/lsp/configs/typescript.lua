-- lua/yoda/lsp/configs/typescript.lua
-- TypeScript/JavaScript language server configuration

local M = {}

--- Create ts_ls configuration
--- @param builder LSPConfigBuilder
--- @return table
function M.create_config(builder)
  return builder
    :with_filetypes({ "typescript", "javascript", "typescriptreact", "javascriptreact" })
    :with_settings({
      typescript = {
        suggest = {
          completeFunctionCalls = true,
        },
        preferences = {
          importModuleSpecifier = "non-relative",
        },
      },
      javascript = {},
    })
    :with_inlay_hints(true)
    :with_init_options({
      preferences = {
        disableSuggestions = false,
      },
    })
    :build()
end

return M
