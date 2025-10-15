# OpenCode Shell Functions and Aliases
# Add this to your ~/.bashrc, ~/.zshrc, or shell config

# Quick setup function
opencode-setup() {
    local project_type=${1:-generic}
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    
    echo "Setting up OpenCode for: $(basename "$repo_root")"
    
    # Auto-detect project type if not specified
    if [[ "$project_type" == "generic" ]]; then
        if [[ -f "$repo_root/package.json" ]]; then
            project_type="javascript"
        elif [[ -f "$repo_root/Cargo.toml" ]]; then
            project_type="rust"
        elif [[ -f "$repo_root/pyproject.toml" ]] || [[ -f "$repo_root/requirements.txt" ]]; then
            project_type="python"
        elif find "$repo_root" -name "*.lua" -type f | head -1 | grep -q .; then
            project_type="lua"
        fi
    fi
    
    # Create opencode.json
    cat > "$repo_root/opencode.json" << 'EOF'
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

    # Create AGENTS.md based on type
    case $project_type in
        lua)
            _create_lua_agents "$repo_root"
            ;;
        javascript|typescript|node)
            _create_js_agents "$repo_root"
            ;;
        python)
            _create_python_agents "$repo_root"
            ;;
        rust)
            _create_rust_agents "$repo_root"
            ;;
        *)
            _create_generic_agents "$repo_root"
            ;;
    esac
    
    # Create basic CLAUDE.md if it doesn't exist
    if [[ ! -f "$repo_root/CLAUDE.md" ]]; then
        _create_claude_md "$repo_root"
    fi
    
    echo "✅ OpenCode setup complete for $project_type project!"
}

# Helper functions (abbreviated for space - full versions would go here)
_create_lua_agents() {
    cat > "$1/AGENTS.md" << 'EOF'
# Project Guidelines

This project uses Lua with dependency injection patterns and comprehensive testing.

- Follow **DRY**, **SOLID**, and **CLEAN** code principles
- Use `snake_case` naming conventions
- Write comprehensive tests with `plenary.nvim`
- Maintain cyclomatic complexity ≤ 7
EOF
}

_create_js_agents() {
    cat > "$1/AGENTS.md" << 'EOF'
# Project Guidelines

This project uses modern JavaScript/TypeScript patterns.

- Follow **DRY**, **SOLID**, and **CLEAN** code principles  
- Use TypeScript for type safety
- Follow ESLint/Prettier configurations
- Write unit tests with Jest/Vitest
EOF
}

_create_python_agents() {
    cat > "$1/AGENTS.md" << 'EOF'
# Project Guidelines

This project follows Python best practices.

- Follow **DRY**, **SOLID**, and **CLEAN** code principles
- Use PEP 8 style guidelines
- Use type hints for all functions
- Write tests with pytest
EOF
}

_create_rust_agents() {
    cat > "$1/AGENTS.md" << 'EOF'
# Project Guidelines  

This project follows Rust idioms and patterns.

- Follow **DRY**, **SOLID**, and **CLEAN** code principles
- Use rustfmt and clippy
- Follow Rust naming conventions
- Write comprehensive tests
EOF
}

_create_generic_agents() {
    cat > "$1/AGENTS.md" << 'EOF'
# Project Guidelines

This project follows general software engineering best practices.

- Follow **DRY**, **SOLID**, and **CLEAN** code principles
- Use consistent naming conventions  
- Write comprehensive tests
- Use conventional commits
EOF
}

_create_claude_md() {
    cat > "$1/CLAUDE.md" << 'EOF'
# Claude AI Configuration

Project-specific instructions for Claude AI.

## Validation Commands
```bash
# Adjust these commands for your project
make lint && make test
```
EOF
}

# Aliases for convenience
alias oc-setup='opencode-setup'
alias oc-lua='opencode-setup lua'
alias oc-js='opencode-setup javascript'
alias oc-py='opencode-setup python'
alias oc-rust='opencode-setup rust'