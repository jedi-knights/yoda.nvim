# Python Functionality Migration

This document outlines the migration of Python-specific functionality from Yoda.nvim to the standalone `python.nvim` plugin.

## Overview

Yoda.nvim has been updated to remove Python-specific code and integrate with `python.nvim` instead. This provides better separation of concerns and makes Python functionality available to other Neovim distributions.

## Changes Made to Yoda.nvim

### Removed Files
- `lua/yoda/lsp/servers/pyright.lua` - Python LSP configuration moved to python.nvim

### Updated Files

#### `lua/yoda/core/autocmds.lua`
- **Removed**: pytest.nvim auto-loading autocmd for Python test files
- **Reason**: python.nvim handles test file detection and loading

#### `lua/yoda/commands.lua`
- **Removed**: `DeletePytestMarks` command
- **Reason**: Command moved to python.nvim

#### `lua/yoda/plugins/spec/lsp.lua`
- **Removed**: Python-specific LSP servers (pyright, ruff)
- **Removed**: Python formatters (black, autoflake)
- **Removed**: Python linters (pylint, mypy, flake8)
- **Reason**: All Python LSP configuration moved to python.nvim

#### `lua/yoda/plugins/spec/init.lua`
- **Added**: `yoda.plugins.spec.python` to plugin spec loading
- **Reason**: New Python plugin specification

### Added Files

#### `lua/yoda/plugins/spec/python.lua`
- **Purpose**: Python plugin specification for Yoda.nvim
- **Features**:
  - Integrates python.nvim with Yoda.nvim
  - Configures comprehensive Python development environment
  - Maintains compatibility with Yoda.nvim's LSP infrastructure
  - Removes pytest.nvim dependency (handled by python.nvim)

## Integration Benefits

### For Yoda.nvim
1. **Cleaner Architecture**: Python functionality is now properly separated
2. **Reduced Maintenance**: Python-specific code is maintained in python.nvim
3. **Better Modularity**: Python features can be updated independently
4. **Consistent API**: All Python operations go through python.nvim

### For python.nvim
1. **Standalone Plugin**: Can be used with any Neovim distribution
2. **Comprehensive Features**: Includes all Python development tools
3. **Better Testing**: Can be tested independently
4. **Wider Adoption**: Available to users of other distributions

## Configuration

The Python plugin is configured in `lua/yoda/plugins/spec/python.lua` with the following features enabled:

- **Virtual Environment Management**: Auto-detection and activation
- **Code Formatting**: Black and isort integration
- **Linting**: Flake8 and MyPy support
- **Testing**: Pytest and unittest integration
- **Debugging**: Debugpy integration
- **REPL**: Floating terminal with auto-import
- **Package Management**: Pip integration
- **LSP**: Pyright with comprehensive settings

## Migration Notes

### For Users
- All Python functionality remains available through python.nvim
- Commands are now prefixed with `Python` (e.g., `:PythonFormat`, `:PythonLint`)
- Keymaps use `<leader>p` prefix (e.g., `<leader>pf` for format)
- No breaking changes to existing Python workflows

### For Developers
- Python-specific code should be added to python.nvim, not Yoda.nvim
- LSP configuration for Python should use python.nvim's LSP module
- Testing should be done against python.nvim independently

## Future Considerations

1. **Plugin Dependencies**: Consider if other plugins should be moved to standalone plugins
2. **Configuration Management**: Evaluate if configuration should be centralized
3. **Testing Strategy**: Ensure comprehensive testing of both plugins
4. **Documentation**: Keep both plugin documentations in sync

## Commands Available

The following Python commands are now available through python.nvim:

- `:PythonSetup` - Setup Python environment
- `:PythonFormat` - Format current buffer
- `:PythonLint` - Lint current buffer
- `:PythonLintWith <linter>` - Lint with specific linter
- `:PythonTest` - Run tests
- `:PythonDebug` - Start debugging
- `:PythonREPL` - Open REPL
- `:PythonVenvPicker` - Virtual environment picker
- `:PythonPackagePicker` - Package picker
- `:PythonTestPicker` - Test picker
- `:PythonImportPicker` - Import picker
- `:PythonInfo` - Show Python information
- `:DeletePytestMarks` - Delete pytest marks

## Keymaps Available

- `<leader>pv` - Virtual environment picker
- `<leader>pf` - Format buffer
- `<leader>pl` - Lint buffer
- `<leader>pt` - Run tests
- `<leader>pd` - Start debugging
- `<leader>pr` - Open REPL
- `<leader>po` - Organize imports
- `<leader>pp` - Package picker
- `<leader>pi` - Import picker
- `<leader>p?` - Show info 