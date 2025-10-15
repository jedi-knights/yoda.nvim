# Yoda.nvim - AI Assistant Context

## Project Overview

Yoda.nvim is a comprehensive Neovim distribution focused on providing an excellent development experience with AI integration, LSP support, and modern development tools.

## Validation Commands

**IMPORTANT**: After making any code changes, always run these validation commands:

### Linting
```bash
make lint
```
- Checks Lua code style using `stylua`
- Excludes files with goto labels (`yaml_parser.lua`, `config_loader.lua`)
- Fix issues with `make format` if possible

### Testing  
```bash
make test
```
- Runs all unit tests using `plenary.nvim` test framework
- Provides aggregate summary at the end
- Individual test files can be found in `tests/unit/`

### Other Available Commands
```bash
make test-unit         # Run only unit tests
make test-integration  # Run integration tests  
make format           # Auto-format code with stylua
make help            # Show all available commands
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

## When Making Changes

1. Always run `make lint` after changes
2. Always run `make test` to ensure nothing breaks
3. Fix any linting or test failures before considering changes complete
4. Add tests for new functionality when appropriate