-- lua/yoda/lsp.lua
-- LSP configuration - simplified and modular

-- Initialize the LSP system using dependency injection and modular architecture
-- All LSP functionality is now organized into focused, testable modules:
-- - services/lsp_manager.lua: Core LSP server management
-- - services/keymap_service.lua: LSP keymap handling
-- - services/config_builder.lua: Configuration factory pattern
-- - services/filetype_detector.lua: Intelligent file type detection
-- - services/python_venv_service.lua: Python virtual environment integration
-- - configs/*.lua: Individual server configurations

local lsp_system = require("yoda.lsp")

-- Initialize the entire LSP system
lsp_system.setup()
