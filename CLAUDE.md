# Yoda.nvim - AI Assistant Context

## Project Overview

Yoda.nvim is a comprehensive Neovim distribution focused on providing an excellent development experience with AI integration, LSP support, and modern development tools.

## Validation Commands

**IMPORTANT**: Run validation commands strategically to save time and tokens:

### When to Run Tests and Lint

**Run validation when:**
- ✅ Completing a logical unit of work (feature, bug fix, refactor)
- ✅ Before marking a task as complete
- ✅ User explicitly requests validation
- ✅ Making changes that could break existing functionality
- ✅ Adding new test files or modifying test infrastructure

**Skip validation for:**
- ❌ Fine-grained incremental changes (single line edits, typo fixes)
- ❌ Documentation-only changes (*.md files)
- ❌ Intermediate steps in a multi-step task
- ❌ Adding comments or whitespace changes
- ❌ Changes to non-code files (.gitignore, etc.)

### Testing
```bash
make test              # Run all specs with coverage (via neospec)
make test-verbose      # Run with verbose output (for CI/debugging)
```
- Test runner: `neospec` (binary installed via `make install`)
- Spec discovery and coverage settings live in `neospec.toml`
- Specs use plenary-style `describe` / `it` blocks under `tests/unit/**/*_spec.lua`

### Linting
```bash
make lint              # Check code style with stylua
make format            # Auto-format code with stylua
```
- Runs `stylua --check` over every `.lua` file under `lua/` and `tests/`
- File-level excludes (e.g., goto-label files) are configured in `stylua.toml`

### Other Available Commands
```bash
make install           # Install / update the neospec test runner
make benchmark         # Run all performance benchmarks
make benchmark-startup # Startup time
make benchmark-buffers # Buffer switching
make benchmark-files   # File operations
make benchmark-memory  # Memory usage
make benchmark-lsp     # LSP operations
make benchmark-clean   # Remove benchmark output
make clean             # Clean generated files
make help              # Show all available commands
```

## Code Style

- Uses `stylua` for Lua formatting
- Follow existing patterns in the codebase
- Preserve dependency injection patterns where used
- Maintain test coverage for new functionality

## Testing Framework

- Runner: `neospec` (Go binary) — configured by `neospec.toml`, bootstrapped by `tests/minimal_init_fast.lua`
- Specs use plenary-style `describe` / `it` blocks
- Test files mirror the `lua/` directory structure in `tests/unit/`
- Coverage is collected for `lua/yoda/` and written to `coverage/` in `console` and `lcov` formats
- Mock patterns are used for external dependencies

## Architecture Notes

- Heavy use of dependency injection patterns
- Modular design with clear separation of concerns
- Adapter pattern for external integrations
- Comprehensive logging system with multiple strategies

## Distribution Stability Preferences

**IMPORTANT**: Yoda.nvim prioritizes stability and reliability over bleeding-edge features.

### Plugin Management
- **Prefer stable releases** over latest commits or nightly builds
- **Pin plugin versions** in `lazy-lock.json` - only update intentionally
- **Test thoroughly** before adopting new plugins or major version updates
- **Avoid experimental features** unless explicitly requested by user
- **Maintain backwards compatibility** when making internal changes

### Update Policy
- **Conservative updates**: Only update when fixing bugs or adding requested features
- **No breaking changes** without clear migration path and documentation
- **Validate after updates**: Always run full test suite and manual smoke tests
- **Document changes**: Update ADRs and changelog for significant updates

### Decision Framework
When considering changes, ask:
1. Does this improve stability or introduce risk?
2. Is this feature proven and well-tested in the community?
3. Can we achieve the same goal with existing stable tools?
4. What's the rollback plan if this causes issues?

**Priority order**: Stability > Functionality > Performance > Latest Features

## When Making Changes

1. Make incremental changes efficiently
2. Run `make lint` and `make test` when completing a logical unit of work
3. Fix any linting or test failures before marking task complete
4. Add tests for new functionality when appropriate
5. Inform user when validation is skipped for efficiency