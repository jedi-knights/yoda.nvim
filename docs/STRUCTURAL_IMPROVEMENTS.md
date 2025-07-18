# Structural Improvement Suggestions for Yoda Neovim Distribution

These recommendations are designed to help keep your configuration DRY (Don't Repeat Yourself), minimize cyclomatic complexity, and maintain a clean, maintainable codebase.

---

## 1. Plugin Specification Consolidation
- **Current:** Many plugin specs are split into single-file-per-plugin under `lua/yoda/plugins/spec/<category>/`.
- **Suggestion:** For categories with many small plugin files (e.g., `lsp`, `ui`, `git`), consolidate related plugins into a single file per category (e.g., `lsp.lua`, `ui.lua`, `git.lua`). Use tables to list plugins. This reduces boilerplate and makes it easier to see all related plugins at a glance.

---

## 2. Keymap Management
- **Current:** All keymaps are in a single, large `keymaps.lua` file.
- **Suggestion:**
  - Split keymaps by domain (e.g., `lsp_keymaps.lua`, `ui_keymaps.lua`, `test_keymaps.lua`) and require them in the main `keymaps.lua`.
  - Use a helper function to register keymaps in a DRY way, especially for repetitive patterns (e.g., LSP, test runners).
  - Consider generating keymaps from a table of definitions to reduce repetition.

---

## 3. Autocommand and Option Organization
- **Current:** All autocommands and options are in single files.
- **Suggestion:**
  - Group related autocommands (e.g., UI, LSP, filetype) into separate modules.
  - For options, use tables to group related settings and iterate over them for assignment.

---

## 4. Plugin Configuration Patterns
- **Current:** Some plugin configs are inline in the spec, others are in separate files.
- **Suggestion:**
  - Standardize on one pattern: either always inline simple configs, or always use a `config/` directory for complex plugin setups.
  - For plugins with similar setup (e.g., LSP servers), use a shared setup function to avoid repeated code.

---

## 5. Reduce Cyclomatic Complexity in Lua Modules
- **Current:** Some modules (e.g., `keymaps.lua`, `testpicker/init.lua`) have long functions with nested conditionals.
- **Suggestion:**
  - Break long functions into smaller, single-purpose functions.
  - Use early returns to reduce nesting.
  - Move repeated logic (e.g., buffer/window iteration) into utility functions.

---

## 6. Documentation Structure
- **Current:** Docs are well-organized, but some references may be outdated after file moves.
- **Suggestion:**
  - Periodically run a link checker on your docs.
  - Consider a `docs/architecture.md` for high-level design and DRY principles.

---

## 7. General DRY Improvements
- Use utility modules for repeated patterns (e.g., buffer/window iteration, notifications, LSP setup).
- Leverage tables and iteration for repetitive config (e.g., setting options, registering keymaps).
- Centralize configuration for things like colors, icons, and plugin options.

---

## 8. Testing and DevTools
- **Current:** Custom test picker and devtools are present.
- **Suggestion:**
  - Move devtools and test utilities into a `lua/yoda/devtools/` or `lua/yoda/tools/` directory.
  - Document their usage and entry points in a single place.

---

## 9. Cyclomatic Complexity Hotspots
- Scan for large functions (over 20 lines or with many branches) and refactor into smaller helpers.
- Automate complexity checks with a Lua linter or static analysis tool (e.g., luacheck, selene).

---

## 10. Example: DRY Keymap Registration
Instead of:
```lua
kmap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Go to Definition" })
kmap.set("n", "<leader>li", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
-- etc.
```
Use:
```lua
local lsp_keymaps = {
  ld = { vim.lsp.buf.definition, "Go to Definition" },
  li = { vim.lsp.buf.implementation, "Go to Implementation" },
  -- ...
}
for key, map in pairs(lsp_keymaps) do
  kmap.set("n", "<leader>"..key, map[1], { desc = map[2] })
end
```

---

## 11. Consider a Bootstrap Script
- For onboarding, a single `:YodaBootstrap` command could set up all recommended tools, check dependencies, and guide the user through optional features.

---

**If you’d like to see a refactor of a specific area, let me know!** 