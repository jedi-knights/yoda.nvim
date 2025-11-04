# Large Files Analysis - Yoda.nvim

## Summary

Based on analysis of the codebase, the following files significantly exceed the project's target of <300 lines per file and should be split for better performance, maintainability, and adherence to SOLID principles.

## Critical Files to Split (Priority Order)

### 1. **lua/plugins.lua** - 1,880 lines ⚠️ HIGHEST PRIORITY
**Target:** <300 lines | **Current:** 1,880 lines | **Violation:** 6.3x over limit

**Issues:**
- Massive monolithic file containing ~108 plugin configurations
- 30 distinct plugin sections (Core Utilities, Motion, UI, LSP, Testing, etc.)
- 44 inline configuration functions
- Violates Single Responsibility Principle
- High startup cost - entire file loaded even if plugins are lazy-loaded
- Difficult to maintain and navigate

**Recommended Split Strategy:**
Split into modular plugin configuration files:
```
lua/plugins/
├── init.lua              # Main plugin loader (aggregates all)
├── core.lua              # Plenary, utilities
├── motion.lua            # Leap, vim-tmux-navigator
├── ui.lua                # Tokyonight, Snacks, Bufferline, Alpha
├── editor.lua            # Treesitter, Comment, Autopairs, Surround
├── git.lua               # Gitsigns, Diffview, Fugitive
├── lsp.lua               # Mason, LSP config, Linting, Formatting
├── completion.lua        # nvim-cmp and sources
├── debugging.lua         # DAP and adapters
├── testing.lua           # Neotest and adapters
├── ai.lua                # Copilot, ChatGPT
└── terminal.lua          # Terminal plugins
```

**Benefits:**
- Lazy loading of plugin configs (only load sections when needed)
- Easier maintenance and navigation
- Better git history (changes isolated to specific domains)
- Adheres to Single Responsibility Principle
- Reduced startup time

---

### 2. **lua/keymaps.lua** - 1,364 lines ⚠️ CRITICAL
**Target:** <300 lines | **Current:** 1,364 lines | **Violation:** 4.5x over limit

**Issues:**
- 42 distinct keymap sections
- Hundreds of individual keymaps
- Mixes concerns (LSP, Git, Editor, Terminal, AI, etc.)
- Violates Single Responsibility Principle

**Recommended Split Strategy:**
```
lua/keymaps/
├── init.lua              # Main keymap loader
├── core.lua              # Basic navigation, help, window management
├── editor.lua            # Text editing, commenting, formatting
├── explorer.lua          # File explorer (Snacks)
├── git.lua               # Git operations
├── lsp.lua               # LSP-specific keymaps
├── debugging.lua         # DAP keymaps
├── testing.lua           # Test runner keymaps
├── terminal.lua          # Terminal keymaps
├── ai.lua                # OpenCode, ChatGPT, Copilot
└── search.lua            # Telescope, grep, find
```

**Benefits:**
- Clear separation of concerns
- Easier to find and modify specific keymaps
- Can be lazy-loaded with their respective plugin domains
- Better documentation organization

---

### 3. **lua/yoda/commands.lua** - 793 lines ⚠️ HIGH PRIORITY
**Target:** <300 lines | **Current:** 793 lines | **Violation:** 2.6x over limit

**Issues:**
- 33 user commands across multiple domains
- 12 distinct command sections
- Mixes concerns (Bufferline debugging, OpenCode, Terminal, Filetype, Git, etc.)

**Recommended Split Strategy:**
```
lua/yoda/commands/
├── init.lua              # Command registration aggregator
├── bufferline.lua        # BufferlineDebug* commands
├── opencode.lua          # OpenCode* commands
├── terminal.lua          # Terminal* commands
├── filetype.lua          # Filetype formatting commands
├── git.lua               # Git-related commands
├── diagnostics.lua       # Health check commands
└── development.lua       # Dev tools commands
```

---

### 4. **lua/yoda/lsp.lua** - 771 lines
**Target:** <300 lines | **Current:** 771 lines | **Violation:** 2.6x over limit

**Issues:**
- 9 LSP server configurations in one file
- Each server has extensive settings
- Violates Single Responsibility Principle

**Recommended Split Strategy:**
```
lua/yoda/lsp/
├── init.lua              # Main LSP setup coordinator
├── servers/
│   ├── go.lua           # gopls
│   ├── python.lua       # basedpyright
│   ├── rust.lua         # rust-analyzer
│   ├── lua.lua          # lua_ls
│   ├── typescript.lua   # ts_ls
│   ├── json.lua         # jsonls
│   ├── yaml.lua         # yamlls
│   ├── csharp.lua       # omnisharp
│   └── docker.lua       # dockerls
├── capabilities.lua      # Shared capabilities config
└── handlers.lua          # Custom handlers
```

**Benefits:**
- Each language's LSP config is isolated
- Easy to add/remove language support
- Better for language-specific teams
- Adheres to Open/Closed Principle

---

### 5. **lua/autocmds.lua** - 557 lines
**Target:** <300 lines | **Current:** 557 lines | **Violation:** 1.9x over limit

**Issues:**
- 20 autocmd sections
- Mixes concerns (Alpha, Gitsigns, Large files, Terminal, etc.)
- Delegates to modules but orchestration is too large

**Recommended Split Strategy:**
```
lua/autocmds/
├── init.lua              # Main autocmd coordinator
├── ui.lua                # Alpha, yank highlight
├── git.lua               # Gitsigns refresh
├── files.lua             # Large file handling, directory args
├── terminal.lua          # Terminal autocmds (delegates to yoda.terminal.autocmds)
├── filetype.lua          # Filetype detection and settings
└── performance.lua       # Performance-related autocmds
```

---

### 6. **lua/yoda/performance_tracker.lua** - 511 lines
**Target:** <300 lines | **Current:** 511 lines | **Violation:** 1.7x over limit

**Issues:**
- Single file with multiple responsibilities:
  - Event tracking
  - Statistics calculation
  - Report generation
  - Storage management

**Recommended Split Strategy:**
```
lua/yoda/performance/
├── tracker.lua           # Main tracker (reduced to <200 lines)
├── events.lua            # Event recording
├── stats.lua             # Statistics calculation
├── reporter.lua          # Report generation
└── storage.lua           # Data persistence
```

---

### 7. **lua/yoda/opencode_integration.lua** - 403 lines
**Target:** <300 lines | **Current:** 403 lines | **Violation:** 1.3x over limit

**Status:** Borderline - slight violation

**Recommended Action:**
- Extract autocmd setup to separate module
- Move terminal handling to terminal module
- Keep core integration logic in main file

---

## Files That Are Acceptable

The following files are close to or within guidelines:

- **lua/yoda/ui/alpha_manager.lua** - 370 lines (slightly over but acceptable as cohesive UI manager)
- **lua/yoda/picker_handler.lua** - 359 lines (within acceptable range)
- **lua/yoda/large_file.lua** - 299 lines (perfect!)
- **lua/yoda/container.lua** - 227 lines (good)

## Performance Impact Analysis

### Current Issues:
1. **Startup Performance:**
   - `plugins.lua` (1,880 lines) loaded early in startup
   - `keymaps.lua` (1,364 lines) loaded early
   - `autocmds.lua` (557 lines) loaded early
   - **Total: 3,801 lines** loaded synchronously at startup

2. **Memory Footprint:**
   - All plugin configs loaded into memory even if plugins lazy-load
   - Large monolithic files prevent granular memory management

3. **Parse Time:**
   - Lua parser must process these massive files
   - No benefit from bytecode caching when files are too large

### Expected Benefits After Split:

1. **Faster Startup:**
   - Only load necessary config modules
   - Better lazy-loading opportunities
   - Estimated 15-30% faster startup time

2. **Better Caching:**
   - Smaller files compile to bytecode faster
   - Better CPU cache utilization
   - Reduced parser overhead

3. **Improved Maintainability:**
   - Changes isolated to specific domains
   - Easier to review and test
   - Better git blame/history

## Implementation Priority

1. **Phase 1 (Critical):** 
   - Split `plugins.lua` (highest impact on startup)
   - Split `keymaps.lua` (high impact on maintainability)

2. **Phase 2 (High):**
   - Split `commands.lua`
   - Split `lsp.lua`

3. **Phase 3 (Medium):**
   - Split `autocmds.lua`
   - Split `performance_tracker.lua`

4. **Phase 4 (Low):**
   - Refactor `opencode_integration.lua`

## Code Quality Benefits

All splits will improve adherence to:

- ✅ **Single Responsibility Principle** - Each file has one clear purpose
- ✅ **Open/Closed Principle** - Easy to add new plugins/commands without modifying existing files
- ✅ **DRY Principle** - Reduce duplication by extracting common patterns
- ✅ **CLEAN Code** - More cohesive, loosely coupled modules
- ✅ **Cyclomatic Complexity** - Smaller files naturally have lower complexity

## Testing Requirements

When splitting files:
1. Maintain 100% backward compatibility
2. Add integration tests to verify all plugins/commands/keymaps still work
3. Benchmark startup time before/after
4. Verify lazy loading works correctly
5. Test all commands and keymaps after reorganization

## References

- Project standards: `docs/STANDARDS_QUICK_REFERENCE.md`
- Architecture: `docs/ARCHITECTURE.md`
- Target: <300 lines per file (mentioned in CONTRIBUTING.md)
