#!/bin/bash

# OpenCode Repository Setup Script
# Usage: ./setup-opencode.sh [project-type]

set -e

# Function definitions
create_lua_agents_md() {
  cat > "$REPO_ROOT/AGENTS.md" << 'EOF'
# Project Guidelines

This project adheres to the following software engineering principles:

- Always write code that follows **DRY (Don't Repeat Yourself)** principles.
- Always write code that follows **SOLID** principles.
- Always write code that follows **CLEAN code** principles.
- Always write code with a **cyclomatic complexity of 7 or less**.
- Always write code that uses **Dependency Injection (DI)** to maximize testability.
- Prefer the use of **Gang of Four (GoF)** design patterns where appropriate.
- Always write code that is **testable with mocks** when appropriate.

## Lua-Specific Guidelines

- Follow Lua naming conventions (`snake_case` for variables and functions)
- Use proper module patterns with `return` statements
- Preserve existing dependency injection patterns
- Maintain compatibility with Neovim's Lua runtime
- Use `stylua` formatting standards
- Write comprehensive unit tests using `plenary.nvim`

## Architecture Patterns

- **Dependency Injection**: Use constructor injection and container patterns
- **Adapter Pattern**: For external integrations
- **Factory Pattern**: For creating strategy instances
- **Strategy Pattern**: For configurable behaviors
- **Observer Pattern**: For event-driven components

## Testing Requirements

- All new modules must have corresponding unit tests
- Use mocks for external dependencies
- Maintain high test coverage
- Tests must pass before committing changes
EOF
}

create_js_agents_md() {
  cat > "$REPO_ROOT/AGENTS.md" << 'EOF'
# Project Guidelines

This project adheres to the following software engineering principles:

- Always write code that follows **DRY (Don't Repeat Yourself)** principles.
- Always write code that follows **SOLID** principles.
- Always write code that follows **CLEAN code** principles.
- Always write code with a **cyclomatic complexity of 7 or less**.
- Always write code that uses **Dependency Injection (DI)** to maximize testability.
- Prefer the use of **Gang of Four (GoF)** design patterns where appropriate.
- Always write code that is **testable with mocks** when appropriate.

## JavaScript/TypeScript Guidelines

- Use TypeScript for type safety when available
- Follow ESLint and Prettier configurations
- Use modern ES6+ features
- Prefer `const` and `let` over `var`
- Use async/await over Promise chains
- Follow conventional naming (`camelCase` for variables, `PascalCase` for classes)

## Testing Requirements

- Write unit tests for all business logic
- Use Jest/Vitest or similar testing frameworks
- Mock external dependencies
- Maintain high test coverage (80%+)
- Use descriptive test names
EOF
}

create_python_agents_md() {
  cat > "$REPO_ROOT/AGENTS.md" << 'EOF'
# Project Guidelines

This project adheres to the following software engineering principles:

- Always write code that follows **DRY (Don't Repeat Yourself)** principles.
- Always write code that follows **SOLID** principles.
- Always write code that follows **CLEAN code** principles.
- Always write code with a **cyclomatic complexity of 7 or less**.
- Always write code that uses **Dependency Injection (DI)** to maximize testability.
- Prefer the use of **Gang of Four (GoF)** design patterns where appropriate.
- Always write code that is **testable with mocks** when appropriate.

## Python Guidelines

- Follow PEP 8 style guidelines
- Use type hints for all function signatures
- Use `snake_case` for variables and functions
- Use `PascalCase` for classes
- Prefer comprehensions over loops when readable
- Use context managers for resource handling
- Follow existing linting rules (black, flake8, mypy)

## Testing Requirements

- Write unit tests using pytest
- Use fixtures for test setup
- Mock external dependencies
- Maintain high test coverage
- Use descriptive test function names
EOF
}

create_rust_agents_md() {
  cat > "$REPO_ROOT/AGENTS.md" << 'EOF'
# Project Guidelines

This project adheres to the following software engineering principles:

- Always write code that follows **DRY (Don't Repeat Yourself)** principles.
- Always write code that follows **SOLID** principles.
- Always write code that follows **CLEAN code** principles.
- Always write code with a **cyclomatic complexity of 7 or less**.
- Prefer the use of **Gang of Four (GoF)** design patterns where appropriate.
- Always write code that is **testable** when appropriate.

## Rust Guidelines

- Follow Rust naming conventions (`snake_case` for variables, `PascalCase` for types)
- Use `rustfmt` for consistent formatting
- Follow Clippy suggestions for idiomatic code
- Prefer owned types over borrowed when reasonable
- Use `Result` and `Option` types appropriately
- Write comprehensive documentation with `///` comments
- Use `cargo test` for testing

## Testing Requirements

- Write unit tests in the same file using `#[cfg(test)]`
- Write integration tests in `tests/` directory
- Use mock objects when testing external dependencies
- Maintain high test coverage
EOF
}

create_generic_agents_md() {
  cat > "$REPO_ROOT/AGENTS.md" << 'EOF'
# Project Guidelines

This project adheres to the following software engineering principles:

- Always write code that follows **DRY (Don't Repeat Yourself)** principles.
- Always write code that follows **SOLID** principles.
- Always write code that follows **CLEAN code** principles.
- Always write code with a **cyclomatic complexity of 7 or less**.
- Always write code that uses **Dependency Injection (DI)** to maximize testability.
- Prefer the use of **Gang of Four (GoF)** design patterns where appropriate.
- Always write code that is **testable with mocks** when appropriate.

## General Guidelines

- Follow consistent naming conventions
- Avoid debugging statements in production code
- Ensure all asynchronous logic handles exceptions properly
- Use conventional commits with Angular convention
- Always run linting and tests before committing changes

## Testing Requirements

- Write comprehensive unit tests for all new functionality
- Use mocks for external dependencies
- Maintain high test coverage
- Tests must pass before committing changes
EOF
}

create_claude_md() {
  cat > "$REPO_ROOT/CLAUDE.md" << 'EOF'
# Claude AI Assistant Configuration

This file contains project-specific instructions for Claude AI when working with this repository.

## Validation Commands

When making changes to this project, always run these validation commands:

```bash
# Run linting (adjust command based on project)
make lint
# OR
npm run lint
# OR  
cargo clippy

# Run tests
make test
# OR
npm test
# OR
cargo test
```

## Project Context

Brief description of what this project does and any important architectural decisions.

## Common Tasks

List common development tasks and their commands here.
EOF
}

# Main script execution
main() {
  local PROJECT_TYPE=${1:-generic}
  REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

  echo "Setting up OpenCode configuration for: $REPO_ROOT"

  # Create opencode.json
  cat > "$REPO_ROOT/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "AGENTS.md",
    "CLAUDE.md",
    "docs/OPENCODE.md",
    "CONTRIBUTING.md"
  ]
}
EOF

  # Create AGENTS.md based on project type
  case $PROJECT_TYPE in
    "lua"|"neovim")
      create_lua_agents_md
      ;;
    "javascript"|"typescript"|"node")
      create_js_agents_md
      ;;
    "python")
      create_python_agents_md
      ;;
    "rust")
      create_rust_agents_md
      ;;
    *)
      create_generic_agents_md
      ;;
  esac

  # Create CLAUDE.md if it doesn't exist
  if [[ ! -f "$REPO_ROOT/CLAUDE.md" ]]; then
    create_claude_md
  fi

  echo "✅ OpenCode configuration created successfully!"
  echo "📁 Files created:"
  echo "   - opencode.json"
  echo "   - AGENTS.md"
  if [[ ! -f "$REPO_ROOT/CLAUDE.md" ]]; then
    echo "   - CLAUDE.md"
  fi
}

# Run main function with all arguments
main "$@"