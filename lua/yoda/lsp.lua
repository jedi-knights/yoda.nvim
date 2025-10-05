-- lua/yoda/lsp.lua
-- LSP configuration

local lspconfig = require("lspconfig")

-- Lua LSP
lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- Go LSP
lspconfig.gopls.setup({})

-- TypeScript/JavaScript LSP
lspconfig.ts_ls.setup({})

-- Setup keymaps for LSP
local function on_attach(client, bufnr)
  local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- LSP keymaps
  map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
  map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
  map("n", "K", vim.lsp.buf.hover, { desc = "Show hover" })
  map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
  map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Show signature help" })
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder" })
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder" })
  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, { desc = "List workspace folders" })
  map("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
  map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
  map("n", "gr", vim.lsp.buf.references, { desc = "Show references" })
  map("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "Format" })
end

-- Set up LSP keymaps for all LSP clients
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = on_attach,
})
