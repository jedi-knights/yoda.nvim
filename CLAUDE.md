# Yoda.nvim - AI Assistant Context

## Project Overview

Yoda.nvim is a comprehensive Neovim distribution focused on providing an excellent development experience with AI integration, LSP support, and modern development tools.

## Validation Commands

**IMPORTANT**: After making any code changes, always run these validation commands:

### Testing  
```bash
make test              # Run all tests (optimized for speed)
make test-verbose      # Run tests with detailed output (for CI/debugging)
```
- Uses `plenary.nvim` test framework
- Runs 542 tests in ~2-3 seconds 
- Individual test files can be found in `tests/unit/`

### Linting
```bash
make lint              # Check code style with stylua
make format            # Auto-format code with stylua
```
- Checks Lua code style using `stylua`
- Excludes files with goto labels (`yaml_parser.lua`, `config_loader.lua`)

### Other Available Commands
```bash
make test-unit         # Run only unit tests
make test-integration  # Run integration tests  
make help             # Show all available commands
```

## Code Style

- Uses `stylua` for Lua formatting
- Follow existing patterns in the codebase
- Preserve dependency injection patterns where used
- Maintain test coverage for new functionality

## Testing Framework

- Uses `plenary.nvim` test harness
- Test files mirror the `lua/` directory structure in `tests/unit/`
- Tests include both unit tests and integration tests
- Mock patterns are used for external dependencies

## Architecture Notes

- Heavy use of dependency injection patterns
- Modular design with clear separation of concerns
- Adapter pattern for external integrations
- Comprehensive logging system with multiple strategies

## External Dependencies Reference

### Neovim Core
- **Minimum version**: 0.10.1+
- **API Documentation**: https://neovim.io/doc/user/api.html
- **Lua API Guide**: https://neovim.io/doc/user/lua-guide.html
- **Latest releases**: https://github.com/neovim/neovim/releases
- **Key APIs used**: `vim.keymap`, `vim.diagnostic`, `vim.lsp`, `vim.fs`

### Snacks.nvim
- **Current commit**: fe7cfe9800a182274d0f868a74b7263b8c0c020b
- **Repository**: https://github.com/folke/snacks.nvim
- **Documentation**: https://github.com/folke/snacks.nvim/blob/main/README.md
- **Purpose**: Modern UI components and utilities
- **Update policy**: Keep aligned with latest stable releases

### Getting Latest Information

When needing current information about dependencies:

1. **For Neovim APIs**: Provide URL to specific API documentation
   ```
   Check https://neovim.io/doc/user/lua-guide.html for the latest vim.keymap patterns
   ```

2. **For snacks.nvim features**: Request live fetches
   ```
   Fetch https://github.com/folke/snacks.nvim/blob/main/README.md 
   and compare to our usage in lua/plugins/ui.lua
   ```

3. **For breaking changes**: Reference release notes
   ```
   Check https://github.com/neovim/neovim/releases/tag/v0.11.0 
   for breaking changes affecting our config
   ```

## When Making Changes

1. Always run `make lint` after changes
2. Always run `make test` to ensure nothing breaks
3. Fix any linting or test failures before considering changes complete
4. Add tests for new functionality when appropriate