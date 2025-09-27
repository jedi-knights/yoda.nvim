# Claude AI Agent Rules & Guidelines

This file contains coding preferences, conventions, and guardrails for AI agents working on this Neovim configuration project.

## Project Context

This is **yoda.nvim**, a custom Neovim distribution focused on:
- **Lazy.nvim** as the plugin manager
- **Production-ready** configurations with minimal bloat
- **DRY principles** and maintainable code structure
- **Conventional commits** following Angular commit message convention
- **Environment-aware** configurations (work vs home)

## Coding Standards & Conventions

### Language & Style
- **Lua**: Use idiomatic Lua with proper error handling (`pcall`, `vim.notify`)
- **Comments**: Add meaningful comments for complex logic, especially for AI-generated code
- **Naming**: Use descriptive variable names, prefer `snake_case` for Lua
- **Functions**: Keep functions small and focused, avoid deep nesting
- **Error Handling**: Always use `pcall` for external calls, provide fallbacks

### Code Organization
- **DRY Principle**: Avoid code duplication, use helper functions
- **Separation of Concerns**: Keep configuration, logic, and UI separate
- **Modular Design**: Create reusable modules in `lua/yoda/` structure
- **Plugin Specs**: Use the existing pattern in `lua/yoda/plugins/spec/`

### Testing & Quality
- **Test Before Commit**: Ensure configurations work without errors
- **Linting**: Follow `stylua.toml` formatting rules
- **Validation**: Use existing validation utilities in `lua/yoda/utils/`
- **Backwards Compatibility**: Don't break existing functionality

## Agent Guardrails

### Safety Rules
- **Never write secrets**: No API keys, passwords, or sensitive data in code
- **Propose diffs first**: Always show changes before applying them
- **Small changesets**: Keep individual changes focused and reviewable
- **No destructive commands**: Never run shell commands that could damage the system
- **User confirmation**: Ask before making breaking changes or major refactors

### Code Generation Guidelines
- **Include unit tests**: Add test notes or examples for new functionality
- **Documentation**: Add comments explaining complex AI-generated code
- **Fallbacks**: Provide graceful degradation when dependencies are missing
- **Performance**: Avoid blocking operations, use async patterns where possible
- **Memory management**: Don't create memory leaks or global state pollution

### Neovim-Specific Rules
- **Keymap conflicts**: Check existing keymaps before adding new ones
- **Plugin compatibility**: Ensure new plugins don't conflict with existing ones
- **Lazy loading**: Use appropriate loading triggers (`cmd`, `event`, `keys`)
- **Dependencies**: Declare all required dependencies explicitly
- **Configuration**: Follow existing configuration patterns in the project

## Workflow Preferences

### Development Process
1. **Analyze existing code** before making changes
2. **Propose changes** with clear reasoning
3. **Test incrementally** to ensure nothing breaks
4. **Document changes** with meaningful commit messages
5. **Validate integration** with existing tools and workflows

### File Organization
- **Plugin specs**: Add to appropriate files in `lua/yoda/plugins/spec/`
- **Utilities**: Create reusable helpers in `lua/yoda/utils/`
- **Core functionality**: Extend `lua/yoda/core/` modules
- **AI-specific code**: Use `lua/yoda/ai/` for AI-related modules

### Integration Points
- **Lazy.nvim**: Follow existing plugin specification patterns
- **Keymaps**: Extend existing keymap system in `lua/yoda/core/keymaps.lua`
- **Commands**: Add user commands following existing patterns
- **Autocmds**: Use existing autocmd system for event handling

## Context Prompts

When working on this project, the AI should:

1. **Understand the existing architecture** and build upon it rather than replacing it
2. **Maintain consistency** with the project's coding style and organization
3. **Provide clear explanations** for complex changes or new features
4. **Test thoroughly** to ensure configurations work as expected
5. **Follow the DRY principle** and create reusable, maintainable code

## Common Patterns

### Plugin Configuration
```lua
{
  "plugin/name",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "PluginCommand" },
  keys = { { "<leader>key", "<cmd>PluginCommand<cr>", desc = "Description" } },
  config = function()
    require("plugin").setup({
      -- configuration options
    })
  end,
}
```

### Error Handling
```lua
local ok, result = pcall(require, "module")
if not ok then
  vim.notify("Module not available", vim.log.levels.WARN)
  return
end
```

### Keymap Registration
```lua
vim.keymap.set("n", "<leader>key", function()
  -- action
end, { desc = "Description" })
```

Remember: This is a production Neovim configuration used daily. Maintain stability, performance, and usability above all else.
