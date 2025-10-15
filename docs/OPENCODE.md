# OpenCode Usage Guide for Yoda.nvim

This guide provides specific instructions for using OpenCode with the Yoda.nvim project.

## Project Configuration for OpenCode

To optimize OpenCode's behavior for your individual repositories, you can configure project-specific rules and preferences.

### 1. Create an `AGENTS.md` file

Create a file named `AGENTS.md` in the root of your project. This file defines project-level coding principles and stylistic rules that OpenCode agents should follow.

#### Example `AGENTS.md`

```markdown
# Project Guidelines

This project adheres to the following software engineering principles:

- Always write code that follows **DRY (Don't Repeat Yourself)** principles.
- Always write code that follows **SOLID** principles.
- Always write code that follows **CLEAN code** principles.
- Always write code with a **cyclomatic complexity of 7 or less**.
- Always write code that uses **Dependency Injection (DI)** to maximize testability.
- Prefer the use of **Gang of Four (GoF)** design patterns where appropriate.
- Prefer the use of **Dependency Injection containers** to enhance configuration and testability.
- Always write code that is **testable with mocks** when appropriate.

Additional project conventions:

- Follow consistent naming conventions (e.g., `snake_case` for databases, `camelCase` for code).
- Avoid `console.log` or print debugging in production code.
- Ensure all asynchronous logic handles exceptions properly.
- Use conventional commits with Angular convention for all commit messages.
- Always run `make lint` and `make test` before committing changes.
```

The `AGENTS.md` file serves as the main reference for OpenCode's code-generation context.

### 2. Configure `opencode.json`

Add an `opencode.json` file in your repository root to point OpenCode to relevant rule and instruction files.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "AGENTS.md",
    "CLAUDE.md",
    "docs/OPENCODE.md",
    "CONTRIBUTING.md"
  ]
}
```

- The `instructions` array lists files that contain project-specific rules and conventions
- OpenCode merges the contents of these files into its prompt context
- Files are processed in order, with later files taking precedence

### 3. Global Configuration

You can define personal global preferences that apply to all OpenCode projects by creating:

```
~/.config/opencode/AGENTS.md
```

This allows you to set global coding philosophies (e.g., DRY, SOLID, CLEAN) that automatically influence all OpenCode workspaces.

Global and project-specific rules are merged — project rules take precedence when overlaps occur.

### 4. Rule Hierarchy

OpenCode reads instruction files using the following precedence:

1. **Local project** `AGENTS.md` (highest priority)
2. **Referenced** files via `opencode.json`
3. **Global** `~/.config/opencode/AGENTS.md` (lowest priority)

This layered structure allows you to maintain both organization-wide and project-specific coding standards.

### 5. Recommended Setup Summary

| File | Purpose |
|------|---------|
| `AGENTS.md` | Defines core project rules and design philosophy |
| `opencode.json` | Lists additional files that OpenCode should ingest |
| `CLAUDE.md` | Project-specific context and validation commands |
| `~/.config/opencode/AGENTS.md` | Defines global user-wide coding preferences |

## Validation and Quality Assurance

When OpenCode makes changes to your code, it's important to validate that nothing was broken. Here's how to ensure quality:

### 1. Running Lint Checks

Ask OpenCode to run the project's lint command after making changes:

```
After making these changes, please run `make lint` to ensure the code style is correct and fix any linting issues.
```

For this project specifically, the lint command uses `stylua` to check Lua code formatting.

### 2. Running Tests

Always validate that your changes don't break existing functionality:

```
Please run `make test` to ensure all unit tests pass and fix any failing tests.
```

This project includes comprehensive unit tests that cover:
- Core utilities and modules
- Adapter patterns
- Diagnostics functionality
- Logging strategies
- Terminal management

### 3. Validation Workflow

Here's the recommended workflow when asking OpenCode to make significant changes:

1. **Make the requested changes**
2. **Run linting**: `make lint`
3. **Fix any lint issues** that arise
4. **Run tests**: `make test`  
5. **Fix any failing tests**
6. **Verify the changes work as expected**

Example prompt:
```
Refactor the logger module to use dependency injection. After making the changes:
1. Run `make lint` and fix any style issues
2. Run `make test` to ensure all tests pass
3. If any tests fail, debug and fix the issues
```

### 4. Available Make Commands

The project includes these validation commands:

| Command | Purpose |
|---------|---------|
| `make test` | Run all tests with summary |
| `make test-unit` | Run only unit tests |
| `make test-integration` | Run only integration tests |
| `make lint` | Check code style with stylua |
| `make format` | Auto-format code with stylua |
| `make help` | Show all available commands |

### 5. Understanding Test Output

When tests run, you'll see:
- ✅ **PASS**: Test passed
- ❌ **FAIL**: Test failed (needs investigation)
- **Summary**: Aggregate results at the end

Example test output:
```
================================================================================
AGGREGATE TEST RESULTS
================================================================================
Total files: 25
Passed: 23 ✅
Failed: 2 ❌
Success rate: 92%
================================================================================
```

### 6. Fixing Common Issues

**Linting Issues**: Usually formatting problems
```bash
# Fix automatically
make format

# Or check what needs fixing
make lint
```

**Test Failures**: Usually caused by:
- API changes that break existing contracts
- Missing dependencies or modules
- Incorrect assumptions in test setup

**Best Practice**: Always run both `make lint` and `make test` after any significant changes.

### 7. Git Integration

Yoda.nvim automatically refreshes git signs when OpenCode modifies files:

- **Auto-refresh**: Git signs update when OpenCode saves files
- **Focus detection**: Signs refresh when you return to Neovim
- **File change detection**: External file modifications trigger git sign updates
- **Snacks Explorer**: File tree git indicators stay current

This ensures that when OpenCode modifies files, you'll immediately see the git status changes reflected in:
- Gitsigns in the sign column
- Snacks Explorer file tree
- Any other git-aware plugins

The integration works through several autocmds that:
- Refresh git signs on `BufEnter` and `FocusGained`
- Update signs after `BufWritePost` events
- Handle external file changes via `FileChangedShell`

### 8. Commit Message Convention

This project follows **Conventional Commits** using the **Angular convention**. When OpenCode creates commits, ensure they follow this format:

#### Commit Message Structure
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

#### Commit Types
| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(terminal): add Python virtual environment support` |
| `fix` | Bug fix | `fix(logging): resolve memory leak in file strategy` |
| `docs` | Documentation changes | `docs(opencode): add commit message guidelines` |
| `style` | Code style changes (formatting, etc.) | `style: fix indentation in autocmds.lua` |
| `refactor` | Code refactoring | `refactor(adapters): extract common picker interface` |
| `test` | Adding or updating tests | `test(terminal): add comprehensive builder tests` |
| `chore` | Maintenance tasks | `chore: update dependencies` |
| `perf` | Performance improvements | `perf(diagnostics): optimize composite checker` |
| `ci` | CI/CD changes | `ci: add stylua formatting check` |

#### Scopes (Optional)
Use these scopes to indicate the area of change:
- `core` - Core utilities (string, table, io, platform)
- `adapters` - Notification and picker adapters  
- `terminal` - Terminal management and builders
- `logging` - Logging system and strategies
- `diagnostics` - Health checks and diagnostics
- `config` - Configuration and setup
- `tests` - Test-related changes

#### Example Commit Messages
```bash
# Feature addition
feat(terminal): add virtual environment detection

# Bug fix with scope
fix(adapters): resolve notification backend fallback issue

# Documentation update
docs(opencode): add conventional commits guidelines

# Refactoring
refactor(logging): implement factory pattern for strategies

# Test addition
test(core): add comprehensive table utility tests

# Breaking change (note the footer)
feat(adapters)!: redesign picker interface

BREAKING CHANGE: picker.select() now requires options parameter
```

#### OpenCode Commit Prompts
When asking OpenCode to create commits, use prompts like:

```
Please create a commit for these changes using conventional commits with Angular convention. 
The changes add virtual environment support to the terminal builder.
Use an appropriate type, scope, and descriptive message.
```

```
Commit these logging improvements using conventional commits format.
This is a refactoring that implements the factory pattern.
```

#### Validation
The project may include commit message linting in the future. Always use conventional commits to ensure compatibility with:
- Automated changelog generation
- Semantic versioning
- Release automation
- Consistent project history

## Project-Specific Context

### Code Style
- Uses `stylua` for Lua formatting
- Follow existing patterns in the codebase
- Preserve dependency injection patterns where used
- Maintain test coverage for new functionality

### Testing Framework
- Uses `plenary.nvim` test harness
- Test files mirror the `lua/` directory structure in `tests/unit/`
- Tests include both unit tests and integration tests
- Mock patterns are used for external dependencies

### Architecture Notes
- Heavy use of dependency injection patterns
- Modular design with clear separation of concerns
- Adapter pattern for external integrations
- Comprehensive logging system with multiple strategies

## Example OpenCode Prompts

Here are some example prompts that incorporate validation:

### For Code Changes
```
Please modify the notification adapter to support custom icons. After making the changes:
1. Run `make lint` and fix any formatting issues
2. Run `make test` to ensure all tests pass
3. If tests fail, debug and fix the issues
```

### For New Features
```
Add a new terminal builder method for Python virtual environments. Make sure to:
1. Follow the existing dependency injection patterns
2. Add comprehensive unit tests in tests/unit/terminal/
3. Run `make lint` to ensure proper formatting
4. Run `make test` to verify everything works
```

### For Refactoring
```
Refactor the logging strategies to use a factory pattern. Please:
1. Preserve all existing functionality
2. Update any affected tests
3. Run `make lint` and `make test` to validate the changes
4. Fix any issues that arise
```

### For Commits
```
Please implement the requested changes and then create a commit using conventional commits with Angular convention. 
The changes add error handling to the notification adapter.
Use: fix(adapters): improve error handling in notification backend
```

## When Making Changes

1. Always run `make lint` after changes
2. Always run `make test` to ensure nothing breaks
3. Fix any linting or test failures before considering changes complete
4. Add tests for new functionality when appropriate
5. Follow existing code patterns and architecture
6. Use conventional commits with Angular convention for all commit messages