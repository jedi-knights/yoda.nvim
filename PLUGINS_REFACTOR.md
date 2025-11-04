# Plugins.lua Refactoring Plan

## Executive Summary

**Current State:** Single monolithic file with 1,880 lines containing 84 plugin configurations
**Target State:** Modular plugin system with each file <300 lines
**Expected Benefits:**
- 15-30% faster startup time through better lazy-loading
- Improved maintainability and navigation
- Better git history and code review
- Adherence to SOLID principles (especially SRP)

## Current Structure Analysis

### File Statistics
- **Total Lines:** 1,880
- **Total Plugins:** 84 unique plugins
- **Sections:** 15 major categories
- **Violation:** 6.3x over the <300 line target

### Section Breakdown

| Section | Lines | Plugins | Target File |
|---------|-------|---------|-------------|
| Core Utilities | ~20 | 1 (plenary) | `core.lua` |
| Motion & Navigation | ~25 | 2 (leap, tmux-navigator) | `motion.lua` |
| UI & Colors | ~280 | 6 (tokyonight, snacks, bufferline, alpha, noice, lualine) | `ui.lua` |
| LSP & Completion | ~220 | 10 (mason, nvim-cmp, sources) | `lsp.lua`, `completion.lua` |
| File Explorer & Picker | ~60 | 3 (nvim-tree, telescope) | `explorer.lua` |
| AI Integration | ~100 | 2 (copilot, opencode) | `ai.lua` |
| Development Tools | ~25 | 1 (trouble) | `editor.lua` |
| Git Integration | ~140 | 3 (gitsigns, diffview, neogit) | `git.lua` |
| Testing & Debugging | ~260 | 11 (neotest, dap, coverage, pytest-atlas) | `testing.lua`, `debugging.lua` |
| Utilities | ~90 | 5 (treesitter, which-key, showkeys, etc.) | `editor.lua` |
| Rust Development | ~340 | 7 | `lang-rust.lua` |
| Python Development | ~80 | 6 | `lang-python.lua` |
| JavaScript/TypeScript | ~150 | 7 | `lang-javascript.lua` |
| C# / .NET | ~70 | 4 | `lang-csharp.lua` |

## New Directory Structure

```
lua/
├── plugins/
│   ├── init.lua              # Main aggregator (loads all plugin modules)
│   ├── core.lua              # Core utilities (plenary)
│   ├── motion.lua            # Motion plugins (leap, tmux-navigator)
│   ├── ui.lua                # UI components (tokyonight, snacks, bufferline, alpha, noice, lualine)
│   ├── editor.lua            # Editor tools (trouble, treesitter, which-key, aerial, todo-comments)
│   ├── completion.lua        # nvim-cmp and completion sources
│   ├── lsp.lua               # Mason and LSP tooling
│   ├── explorer.lua          # File navigation (nvim-tree, telescope)
│   ├── git.lua               # Git tools (gitsigns, diffview, neogit)
│   ├── testing.lua           # Testing framework (neotest, adapters)
│   ├── debugging.lua         # Debug tools (DAP, coverage)
│   ├── ai.lua                # AI integration (copilot, opencode)
│   ├── lang-rust.lua         # Rust-specific tools
│   ├── lang-python.lua       # Python-specific tools
│   ├── lang-javascript.lua   # JavaScript/TypeScript tools
│   └── lang-csharp.lua       # C# / .NET tools
└── plugins.lua               # [DEPRECATED] Legacy file (symlink or redirect to plugins/init.lua)
```

## Refactoring Strategy

### Phase 1: Setup Infrastructure (Session 1)
**Goal:** Create directory structure and aggregator without breaking existing config

**Steps:**
1. ☐ Create `lua/plugins/` directory
2. ☐ Create `lua/plugins/init.lua` with lazy.nvim compatible structure:
   ```lua
   -- lua/plugins/init.lua
   -- Aggregates all plugin modules for lazy.nvim
   
   local modules = {
     "plugins.core",
     "plugins.motion",
     "plugins.ui",
     "plugins.editor",
     "plugins.completion",
     "plugins.lsp",
     "plugins.explorer",
     "plugins.git",
     "plugins.testing",
     "plugins.debugging",
     "plugins.ai",
     "plugins.lang-rust",
     "plugins.lang-python",
     "plugins.lang-javascript",
     "plugins.lang-csharp",
   }
   
   local plugins = {}
   for _, module in ipairs(modules) do
     local ok, mod = pcall(require, module)
     if ok then
       vim.list_extend(plugins, mod)
     else
       vim.notify("Failed to load plugin module: " .. module, vim.log.levels.WARN)
     end
   end
   
   return plugins
   ```
3. ☐ Update `init.lua` or lazy loading config to point to `plugins/init.lua` instead of `plugins.lua`
4. ☐ Verify lazy.nvim still loads correctly with empty module files

**Validation:**
- ☐ Run `make lint`
- ☐ Start Neovim and verify no errors
- ☐ Run `:Lazy` to verify plugin manager loads

---

### Phase 2: Extract Core & Motion Plugins (Session 2)
**Goal:** Move simplest, least dependent plugins first

**Steps:**
1. ☐ Create `lua/plugins/core.lua`:
   - Extract Plenary configuration (lines ~12-18)
   - Return as array of plugin specs
   ```lua
   -- lua/plugins/core.lua
   return {
     -- Plenary - Lua utility library
     {
       "nvim-lua/plenary.nvim",
       lazy = true,
       ft = "lua",
       event = { "BufReadPre *.spec.lua", "BufReadPre *_spec.lua" },
     },
   }
   ```

2. ☐ Create `lua/plugins/motion.lua`:
   - Extract Leap configuration (lines ~24-30)
   - Extract vim-tmux-navigator (lines ~33-43)
   
**Validation:**
- ☐ Run `make lint`
- ☐ Restart Neovim
- ☐ Verify `:Lazy` shows plenary, leap, vim-tmux-navigator
- ☐ Test leap motions work
- ☐ Test tmux navigation keybinds work

**Files Modified:**
- `lua/plugins/core.lua` (new)
- `lua/plugins/motion.lua` (new)

---

### Phase 3: Extract UI Plugins (Session 3)
**Goal:** Move UI-related plugins (largest section after LSP)

**Steps:**
1. ☐ Create `lua/plugins/ui.lua`:
   - Extract tokyonight (lines ~49-54)
   - Extract snacks (lines ~56-88)
   - Extract bufferline (lines ~90-138)
   - Extract alpha (lines ~139-210)
   - Extract noice (lines ~211-266)
   - Extract lualine (lines ~279-325)
   - Extract nvim-web-devicons (lines ~267-278)

**Validation:**
- ☐ Run `make lint`
- ☐ Restart Neovim
- ☐ Verify colorscheme loads correctly
- ☐ Verify alpha dashboard appears on startup
- ☐ Verify bufferline displays correctly
- ☐ Verify lualine displays git branch
- ☐ Test `:Lazy` shows all UI plugins

**Files Modified:**
- `lua/plugins/ui.lua` (new, ~280 lines)

---

### Phase 4: Extract LSP & Completion (Session 4)
**Goal:** Split LSP infrastructure from completion

**Steps:**
1. ☐ Create `lua/plugins/lsp.lua`:
   - Extract Mason (lines ~329-342)
   - Extract mason-lspconfig (if present)
   - Keep LSP installer/manager tools only
   
2. ☐ Create `lua/plugins/completion.lua`:
   - Extract nvim-cmp (lines ~343-400 approx)
   - Extract LuaSnip
   - Extract friendly-snippets
   - Extract all cmp sources (cmp-nvim-lsp, cmp-buffer, cmp-path, cmp-cmdline)

**Note:** LSP server configurations remain in `lua/yoda/lsp.lua` (separate refactoring tracked in LARGE_FILES_ANALYSIS.md)

**Validation:**
- ☐ Run `make lint`
- ☐ Restart Neovim
- ☐ Open a Lua file, verify LSP attaches
- ☐ Type and verify completion works
- ☐ Test snippet expansion
- ☐ Verify `:Mason` command works

**Files Modified:**
- `lua/plugins/lsp.lua` (new)
- `lua/plugins/completion.lua` (new)

---

### Phase 5: Extract Explorer & Git (Session 5)
**Goal:** Move file navigation and git tools

**Steps:**
1. ☐ Create `lua/plugins/explorer.lua`:
   - Extract nvim-tree (lines ~543-563)
   - Extract telescope (lines ~564-583)
   - Extract telescope-fzf-native (lines ~584-595)
   
2. ☐ Create `lua/plugins/git.lua`:
   - Extract gitsigns (lines ~683-800)
   - Extract diffview (lines ~801-821)
   - Extract neogit (lines ~825-893)

**Validation:**
- ☐ Run `make lint`
- ☐ Restart Neovim
- ☐ Test `<leader>eo` (explorer open)
- ☐ Test `<leader>ff` (telescope find files)
- ☐ Test git signs display in sign column
- ☐ Test `:DiffviewOpen`
- ☐ Test `:Neogit`

**Files Modified:**
- `lua/plugins/explorer.lua` (new)
- `lua/plugins/git.lua` (new)

---

### Phase 6: Extract Testing & Debugging (Session 6)
**Goal:** Separate testing framework from debugging tools

**Steps:**
1. ☐ Create `lua/plugins/testing.lua`:
   - Extract pytest-atlas (lines ~894-910)
   - Extract neotest (lines ~911-1044)
   - Extract neotest-python (lines ~1045-1051)
   - Extract neotest-rust (lines ~1374-1381)
   - Extract neotest-jest (lines ~1778-1784)
   - Extract neotest-vitest (lines ~1785-1791)
   - Extract neotest-dotnet (lines ~1874-1880)
   
2. ☐ Create `lua/plugins/debugging.lua`:
   - Extract nvim-dap (lines ~1052-1061)
   - Extract nvim-dap-ui (lines ~1062-1071)
   - Extract nvim-coverage (lines ~1072-1082)
   - Extract mason-nvim-dap (lines ~1591-1609)

**Validation:**
- ☐ Run `make lint`
- ☐ Restart Neovim
- ☐ Test `<leader>tt` (run nearest test)
- ☐ Test `<leader>ta` (run all tests)
- ☐ Open Python file, set breakpoint, test debugging
- ☐ Verify test output displays correctly

**Files Modified:**
- `lua/plugins/testing.lua` (new, ~260 lines)
- `lua/plugins/debugging.lua` (new)

---

### Phase 7: Extract Editor Utilities (Session 7)
**Goal:** Group general editor enhancement tools

**Steps:**
1. ☐ Create `lua/plugins/editor.lua`:
   - Extract trouble.nvim (lines ~655-679)
   - Extract treesitter (lines ~1136-1177)
   - Extract FixCursorHold (lines ~1178-1187)
   - Extract nvim-nio (lines ~1188-1194)
   - Extract which-key (lines ~1195-1204)
   - Extract showkeys (lines ~1205-1225)
   - Extract aerial.nvim (lines ~1467-1496)
   - Extract todo-comments (lines ~1497-1551)
   - Extract conform.nvim (lines ~1382-1466) [formatter]
   - Extract nvim-lint (if present) [linter]

**Validation:**
- ☐ Run `make lint`
- ☐ Restart Neovim
- ☐ Test `:Trouble` command
- ☐ Verify syntax highlighting works
- ☐ Test `<leader>` shows which-key popup
- ☐ Test `:AerialToggle`
- ☐ Format a file, verify conform.nvim works

**Files Modified:**
- `lua/plugins/editor.lua` (new, ~250 lines)

---

### Phase 8: Extract AI Integration (Session 8)
**Goal:** Consolidate AI tools

**Steps:**
1. ☐ Create `lua/plugins/ai.lua`:
   - Extract copilot.lua (lines ~599-651)
   - Extract opencode.nvim (lines ~1086-1132)

**Validation:**
- ☐ Run `make lint`
- ☐ Restart Neovim
- ☐ Test Copilot suggestions appear
- ☐ Test `<leader>ai` opens OpenCode
- ☐ Verify OpenCode integration works

**Files Modified:**
- `lua/plugins/ai.lua` (new)

---

### Phase 9: Extract Language-Specific Plugins (Session 9)
**Goal:** Isolate language-specific tooling for easier maintenance

**Steps:**
1. ☐ Create `lua/plugins/lang-rust.lua`:
   - Extract rust-tools.nvim (lines ~1229-1333)
   - Extract crates.nvim (lines ~1334-1373)
   - Extract overseer.nvim (lines ~1552-1590)
   - Note: rust-analyzer config stays in `lua/yoda/lsp.lua`
   
2. ☐ Create `lua/plugins/lang-python.lua`:
   - Extract mfussenegger/nvim-dap-python (lines ~1610-1687)
   - Extract venv-selector.nvim (if present)
   - Note: basedpyright config stays in `lua/yoda/lsp.lua`
   
3. ☐ Create `lua/plugins/lang-javascript.lua`:
   - Extract mxsdev/nvim-dap-vscode-js (lines ~1688-1777)
   - Extract package-info.nvim (lines ~1792-1841)
   - Note: ts_ls config stays in `lua/yoda/lsp.lua`
   
4. ☐ Create `lua/plugins/lang-csharp.lua`:
   - Extract roslyn.nvim (lines ~1842-1873)
   - Note: omnisharp config stays in `lua/yoda/lsp.lua`

**Validation:**
- ☐ Run `make lint`
- ☐ Restart Neovim
- ☐ Open Rust file, verify rust-tools features work
- ☐ Open Python file, verify Python-specific features work
- ☐ Open JS/TS file, verify package-info displays
- ☐ Open C# file, verify Roslyn LSP works

**Files Modified:**
- `lua/plugins/lang-rust.lua` (new, ~340 lines)
- `lua/plugins/lang-python.lua` (new, ~80 lines)
- `lua/plugins/lang-javascript.lua` (new, ~150 lines)
- `lua/plugins/lang-csharp.lua` (new, ~70 lines)

---

### Phase 10: Deprecate Old plugins.lua (Session 10)
**Goal:** Remove monolithic file and finalize migration

**Steps:**
1. ☐ Verify all plugins loaded correctly:
   ```lua
   -- Run in Neovim command mode
   :lua vim.notify("Total plugins: " .. #require("lazy").plugins())
   ```
   - Should show 84 plugins
   
2. ☐ Compare plugin lists:
   ```bash
   # Before refactor (save this output first)
   nvim --headless -c "lua print(vim.inspect(require('lazy').plugins()))" -c "qa" > /tmp/plugins_before.txt
   
   # After refactor
   nvim --headless -c "lua print(vim.inspect(require('lazy').plugins()))" -c "qa" > /tmp/plugins_after.txt
   
   # Compare
   diff /tmp/plugins_before.txt /tmp/plugins_after.txt
   ```
   
3. ☐ Rename old file:
   ```bash
   mv lua/plugins.lua lua/plugins.lua.deprecated
   ```
   
4. ☐ Create redirect comment in old location (optional):
   ```lua
   -- lua/plugins.lua
   -- DEPRECATED: This file has been refactored into modular components
   -- New location: lua/plugins/
   -- See: PLUGINS_REFACTOR.md for details
   
   return require("plugins")
   ```

5. ☐ Update documentation:
   - ☐ Update README.md to mention new structure
   - ☐ Update ARCHITECTURE.md
   - ☐ Update CONTRIBUTING.md

**Validation:**
- ☐ Run `make lint`
- ☐ Run `make test`
- ☐ Fresh Neovim start (delete cache first):
   ```bash
   rm -rf ~/.local/share/nvim
   rm -rf ~/.local/state/nvim
   nvim
   ```
- ☐ Verify all 84 plugins load
- ☐ Test representative features from each category
- ☐ Benchmark startup time (compare to baseline)

**Files Modified:**
- `lua/plugins.lua` (deprecated/removed)
- `README.md` (updated)
- `docs/ARCHITECTURE.md` (updated)
- `CONTRIBUTING.md` (updated)

---

## Success Metrics

### Quantitative
- [ ] All 84 plugins load correctly
- [ ] Each plugin module <300 lines
- [ ] Startup time improved by 15-30%
- [ ] All tests pass (`make test`)
- [ ] Lint passes (`make lint`)

### Qualitative
- [ ] Code is more maintainable
- [ ] Easier to find specific plugin configs
- [ ] Better separation of concerns
- [ ] Follows Single Responsibility Principle
- [ ] Improved git history clarity

## Testing Checklist

After each phase, verify:
- [ ] `make lint` passes
- [ ] `make test` passes
- [ ] Neovim starts without errors
- [ ] `:Lazy` shows correct plugins
- [ ] `:checkhealth` shows no new errors
- [ ] Representative features from modified sections work

## Rollback Plan

If issues arise during refactoring:

1. **Immediate Rollback:**
   ```bash
   git reset --hard HEAD
   ```

2. **Phase-by-Phase Rollback:**
   - Revert to last working commit
   - Comment out problematic module in `lua/plugins/init.lua`
   - Continue with other phases

3. **Emergency Fallback:**
   - Restore `lua/plugins.lua.deprecated` → `lua/plugins.lua`
   - Update lazy config to use old file

## Dependencies and Blockers

### Prerequisites
- [ ] Backup current configuration
- [ ] Baseline startup time measurement
- [ ] Save current plugin list for comparison

### External Dependencies
None - this is purely internal refactoring

### Risk Assessment
- **Low Risk:** Core, Motion, AI (few dependencies)
- **Medium Risk:** UI, Editor, Explorer, Git (some interdependencies)
- **High Risk:** LSP, Completion, Testing, Debugging (many cross-dependencies)

## Timeline Estimate

- **Phase 1 (Infrastructure):** 30 minutes
- **Phase 2 (Core/Motion):** 30 minutes
- **Phase 3 (UI):** 45 minutes
- **Phase 4 (LSP/Completion):** 60 minutes
- **Phase 5 (Explorer/Git):** 45 minutes
- **Phase 6 (Testing/Debugging):** 60 minutes
- **Phase 7 (Editor):** 45 minutes
- **Phase 8 (AI):** 20 minutes
- **Phase 9 (Languages):** 60 minutes
- **Phase 10 (Finalize):** 45 minutes

**Total Estimated Time:** 6-7 hours (can be split across multiple sessions)

## Session Tracking

Use this section to track progress across multiple sessions:

### Session Log
| Session | Date | Phases Completed | Notes |
|---------|------|------------------|-------|
| 1 | YYYY-MM-DD | Phase X | ... |
| 2 | YYYY-MM-DD | Phase Y | ... |

### Current Status
- **Last Completed Phase:** None
- **Next Phase:** Phase 1 - Setup Infrastructure
- **Blockers:** None
- **Notes:** Ready to start

## Related Documents

- `LARGE_FILES_ANALYSIS.md` - Analysis of all large files
- `docs/ARCHITECTURE.md` - System architecture
- `docs/STANDARDS_QUICK_REFERENCE.md` - Code standards
- `CONTRIBUTING.md` - Contribution guidelines

## Notes for Future Maintainers

1. **Adding New Plugins:**
   - Add to appropriate module in `lua/plugins/`
   - If creating new language support, use `lang-{name}.lua` pattern
   - Keep each module under 300 lines

2. **Plugin Organization Principles:**
   - UI plugins → `ui.lua`
   - Editor tools → `editor.lua`
   - Language-specific → `lang-{name}.lua`
   - LSP infrastructure → `lsp.lua`
   - Completion → `completion.lua`

3. **Lazy Loading Best Practices:**
   - Use `event = "VeryLazy"` for non-critical plugins
   - Use `ft = "filetype"` for language-specific plugins
   - Use `cmd = "Command"` for command-only plugins
   - Use `keys = {...}` for keymap-only plugins

## Questions and Decisions

### Decision Log
| Date | Decision | Rationale |
|------|----------|-----------|
| YYYY-MM-DD | Split language plugins by language | Better for language-specific teams, easier to add/remove language support |
| YYYY-MM-DD | Keep LSP server configs in `lua/yoda/lsp.lua` | Separate refactoring; plugins vs configuration |

### Open Questions
None currently.

---

**Document Status:** Ready for Phase 1
**Last Updated:** 2025-11-04
**Owner:** Yoda.nvim Maintainers
