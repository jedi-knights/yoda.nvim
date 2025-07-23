-- lua/yoda/utils/lsp.lua
-- LSP configuration utilities

local M = {}

-- Standard LSP settings template
function M.lsp_settings(settings)
  return {
    settings = settings,
  }
end

-- Create Python LSP settings
function M.python_settings(opts)
  opts = opts or {}
  return M.lsp_settings({
    python = {
      analysis = {
        typeCheckingMode = opts.type_checking or "strict",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = opts.diagnostic_mode or "openFilesOnly",
      },
    },
  })
end

-- Create Lua LSP settings
function M.lua_settings(opts)
  opts = opts or {}
  return M.lsp_settings({
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = opts.globals or {
          "vim",
          "describe",
          "it",
          "before_each",
          "after_each",
          "assert",
        },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  })
end

-- Create TypeScript/JavaScript LSP settings
function M.typescript_settings(opts)
  opts = opts or {}
  return M.lsp_settings({
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  })
end

-- Create Go LSP settings
function M.go_settings(opts)
  opts = opts or {}
  return M.lsp_settings({
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
      gofumpt = true,
      usePlaceholders = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  })
end

-- Standard LSP on_attach function
function M.on_attach(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  
  -- LSP keymaps
  vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "<leader>lD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>lrn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>ls", vim.lsp.buf.document_symbol, opts)
  vim.keymap.set("n", "<leader>lw", vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, opts)
end

-- Standard LSP capabilities
function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
  return capabilities
end

return M 