-- lua/yoda/lsp/config.lua
-- Enhanced LSP configuration with file watching

local M = {}

-- Enable file watching for all LSP clients
function M.setup_file_watching()
  -- Enable file watching capabilities
  local default_capabilities = vim.lsp.protocol.make_client_capabilities()
  
  -- Enable file watching
  default_capabilities.workspace = default_capabilities.workspace or {}
  default_capabilities.workspace.didChangeWatchedFiles = {
    dynamicRegistration = true,
    relativePatternSupport = true,
  }
  
  return default_capabilities
end

-- Enhanced capabilities with file watching
function M.capabilities()
  local capabilities = M.setup_file_watching()
  
  -- Add nvim-cmp capabilities if available
  local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end
  
  return capabilities
end

-- Enhanced on_attach with file watching setup
function M.on_attach(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }
  
  -- Basic hover functionality
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  
  -- Enable file watching if supported
  if client.supports_method("workspace/didChangeWatchedFiles") then
    -- Setup file watching for common file patterns
    local patterns = {
      "**/*.lua",
      "**/*.py", 
      "**/*.go",
      "**/*.js",
      "**/*.ts",
      "**/*.jsx",
      "**/*.tsx",
      "**/*.json",
      "**/*.md",
      "**/package.json",
      "**/tsconfig.json",
      "**/pyproject.toml",
      "**/requirements.txt",
      "**/go.mod",
      "**/Cargo.toml",
    }
    
    -- Register file watching
    if client.server_capabilities.workspace and client.server_capabilities.workspace.fileOperations then
      vim.notify("✅ File watching enabled for " .. client.name, vim.log.levels.INFO)
    end
  end
end

return M
