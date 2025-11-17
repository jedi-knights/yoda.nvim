# Plugin Extraction Recommendations

**Analysis Date:** November 17, 2025  
**Distribution:** Yoda.nvim  
**Total Code Analyzed:** ~2,871 lines across core modules

---

## 📊 Executive Summary

After analyzing Yoda.nvim's architecture, **3 modules are excellent candidates** for extraction into standalone plugins. These modules are production-ready, well-tested, generic, and would benefit the broader Neovim community.

**Recommended extraction order:**
1. ⭐ **yoda.nvim-adapters** (foundation layer)
2. ⭐ **yoda-logging.nvim** (optional dependency on adapters)
3. ⭐ **yoda-terminal.nvim** (depends on adapters)

---

## 🎯 HIGH PRIORITY - Ready to Extract

### 1. **`yoda.nvim-adapters`** ⭐⭐⭐⭐⭐

**Repository Description:**  
> Abstract notification and picker backends in Neovim. Auto-detects noice/snacks/telescope or falls back to native APIs. Zero dependencies, DIP-compliant, ~95% test coverage.

**Location:** `lua/yoda/adapters/`  
**Files:** `notification.lua`, `picker.lua` (+ DI versions)  
**LOC:** ~400 lines  
**Test Coverage:** ~95%  
**External Dependencies:** None (pure Neovim APIs)

#### Why Extract

| Criterion | Score | Rationale |
|-----------|-------|-----------|
| **Generic & Reusable** | ⭐⭐⭐⭐⭐ | Works with ANY Neovim config, not Yoda-specific |
| **Well-tested** | ⭐⭐⭐⭐⭐ | Comprehensive test coverage with mocks |
| **Zero Yoda dependencies** | ⭐⭐⭐⭐⭐ | Only depends on `vim.*` APIs |
| **Solves common problem** | ⭐⭐⭐⭐⭐ | Every config needs notification/picker abstraction |
| **Clean API** | ⭐⭐⭐⭐⭐ | Simple, documented, follows DIP principle |

#### Value Proposition

```lua
-- Plugin users get instant multi-backend support:
local notify = require("yoda-adapters.notification")
notify.notify("Hello, World!", "info")
-- ✅ Works with noice, snacks, or native vim.notify automatically!

local picker = require("yoda-adapters.picker")
picker.select(items, { prompt = "Choose:" }, callback)
-- ✅ Works with snacks, telescope, or native vim.ui.select

-- Runtime backend switching:
notify.set_backend("noice")    -- Force noice
picker.set_backend("telescope") -- Force telescope

-- User can configure globally:
vim.g.yoda_notify_backend = "snacks"
vim.g.yoda_picker_backend = "telescope"
```

#### Community Benefits

- **Plugin developers**: Abstract away notification/picker dependencies
- **Config builders**: Easy multi-backend support without boilerplate
- **Testing**: Mock notification/picker behavior easily
- **Graceful degradation**: Automatic fallback to native APIs

#### Technical Details

**Architecture:**
- ✅ Adapter Pattern (GoF)
- ✅ Singleton Pattern (cached backend detection)
- ✅ Dependency Inversion Principle (SOLID)

**Features:**
- Auto-detection of installed backends
- User preference override via global config
- Level normalization (string ↔ number)
- Comprehensive error handling with fallback

**Internal Usage:** 88 requires across Yoda.nvim codebase

---

### 2. **`yoda-terminal.nvim`** ⭐⭐⭐⭐

**Repository Description:**  
> Smart Python virtual environment integration for Neovim terminals. Auto-detects .venv, cross-platform activation (bash/zsh/Windows), interactive selection. Facade + Builder patterns.

**Location:** `lua/yoda/terminal/`  
**Files:** `init.lua`, `shell.lua`, `venv.lua`, `config.lua`, `builder.lua`  
**LOC:** ~600 lines  
**Test Coverage:** Good coverage for critical paths  
**Dependencies:** `yoda.nvim-adapters` (for picker)

#### Why Extract

| Criterion | Score | Rationale |
|-----------|-------|-----------|
| **Unique functionality** | ⭐⭐⭐⭐⭐ | Smart Python venv detection + terminal integration |
| **Well-architected** | ⭐⭐⭐⭐⭐ | Facade + Builder patterns, DI-ready |
| **Comprehensive** | ⭐⭐⭐⭐ | Handles shell detection, venv activation, config |
| **Tested** | ⭐⭐⭐⭐ | Good coverage for core functionality |
| **Standalone value** | ⭐⭐⭐⭐⭐ | Any Python developer would benefit |

#### Value Proposition

```lua
local terminal = require("yoda-terminal")

-- 🚀 Smart venv detection (auto-finds .venv in project root):
terminal.open_floating()

-- 🎯 Explicit venv activation:
terminal.open_floating({ venv_path = "/path/to/.venv" })

-- 🔍 Interactive venv selection (if multiple found):
terminal.select_virtual_env(function(venv_path)
  print("Selected:", venv_path)
end)

-- 🛠️ Builder API for advanced use:
local builder = require("yoda-terminal.builder")
local config = builder
  :with_venv(".venv")
  :with_title("Python Dev")
  :with_shell("zsh")
  :build()

terminal.open_simple(config)

-- 🌍 Cross-platform venv activation:
-- ✅ Bash/Zsh: sources activate script
-- ✅ Windows: uses Scripts/activate
-- ✅ Fallback: opens shell in venv dir
```

#### Community Benefits

- **Python developers**: Zero-config venv activation in terminals
- **Multi-project workflows**: Auto-detects per-project venvs
- **Cross-platform**: Works on Linux, macOS, Windows
- **Flexible**: Simple API + advanced Builder pattern

#### Technical Details

**Architecture:**
- ✅ Facade Pattern (simple API over complex subsystem)
- ✅ Builder Pattern (fluent configuration)
- ✅ Strategy Pattern (shell-specific activation)

**Features:**
- Auto-detects `.venv` in current directory
- Falls back to user selection if multiple venvs found
- Shell-aware activation (bash, zsh, fish, powershell)
- Cross-platform path handling
- Graceful degradation (opens plain terminal if venv fails)

**Target Market:** Python developers, data scientists, ML engineers

---

### 3. **`yoda-logging.nvim`** ⭐⭐⭐⭐

**Repository Description:**  
> Production-ready logging framework for Neovim. Strategy pattern with console/file/notify/multi backends. Lazy evaluation, level filtering, structured context. 77 tests, ~95% coverage.

**Location:** `lua/yoda/logging/`  
**Files:** `logger.lua`, `config.lua`, `formatter.lua`, `strategies/`  
**LOC:** ~500 lines  
**Test Coverage:** ~95% (77 tests)  
**Dependencies:** Optional `yoda.nvim-adapters` (for notify strategy)

#### Why Extract

| Criterion | Score | Rationale |
|-----------|-------|-----------|
| **Production-ready** | ⭐⭐⭐⭐⭐ | Strategy pattern, 77 tests, comprehensive |
| **Zero Yoda coupling** | ⭐⭐⭐⭐⭐ | Generic logging facade, no Yoda dependencies |
| **Multiple strategies** | ⭐⭐⭐⭐⭐ | Console, file, notify, multi (console+file) |
| **Performance optimized** | ⭐⭐⭐⭐⭐ | Lazy evaluation, level filtering |
| **Great documentation** | ⭐⭐⭐⭐⭐ | Comprehensive README with examples |

#### Value Proposition

```lua
local logger = require("yoda-logging")

-- 🎚️ Configure once:
logger.setup({
  strategy = "file",              -- console, file, notify, multi
  level = logger.LEVELS.DEBUG,    -- trace, debug, info, warn, error
  file = {
    path = vim.fn.stdpath("data") .. "/app.log",
    max_size = 1024 * 1024,       -- 1MB
    rotate_count = 3,             -- Keep 3 backups
  },
})

-- 📝 Log at different levels:
logger.trace("Very detailed trace")
logger.debug("Debug information")
logger.info("General information")
logger.warn("Warning message")
logger.error("Error occurred")

-- 🏷️ Add context:
logger.debug("Loading plugin", {
  plugin = "telescope",
  event = "VeryLazy",
  duration_ms = 150,
})

-- ⚡ Lazy evaluation (for performance):
logger.debug(function()
  return "Expensive: " .. vim.inspect(huge_table)
end)
-- Function only called if DEBUG level enabled!

-- 🔄 Runtime strategy switching:
logger.set_strategy("multi")    -- console + file
logger.set_level("trace")       -- most verbose

-- 📊 Output format:
-- [2025-11-17 15:30:45] [DEBUG] Loading plugin | plugin=telescope event=VeryLazy
-- [2025-11-17 15:30:46] [ERROR] Failed to parse | file=config.yaml line=42
```

#### Community Benefits

- **Plugin developers**: Consistent logging API for plugins
- **Power users**: Debug configs without print() statements
- **Troubleshooting**: Ask users to enable file logging for support
- **Performance profiling**: Track operation durations with context

#### Technical Details

**Architecture:**
- ✅ Strategy Pattern (GoF #8) - pluggable backends
- ✅ Facade Pattern - simple API over complex subsystem
- ✅ Lazy evaluation - performance optimization

**Strategies:**
- **Console:** `print()`-based output (development)
- **File:** Persistent logging with rotation (troubleshooting)
- **Notify:** UI-based via adapters (user notifications)
- **Multi:** Console + File combined (comprehensive)

**Features:**
- Level filtering (TRACE, DEBUG, INFO, WARN, ERROR)
- Lazy evaluation (functions only called if logged)
- Context fields (structured logging)
- Timestamp formatting
- File rotation (size-based)
- Flush/clear utilities

**Target Market:** Plugin authors, config builders, power users

---

## 🎯 MEDIUM PRIORITY - Consider Extraction

### 4. **`yoda-core.nvim`** ⭐⭐⭐

**Location:** `lua/yoda/core/`  
**Files:** `string.lua`, `table.lua`, `platform.lua`, `io.lua`, `cache.lua`  
**LOC:** ~300 lines  
**Test Coverage:** Excellent (property-based tests)

#### Why Extract

- **Utility library**: Common operations used throughout Yoda
- **Well-tested**: Property-based tests for string/table
- **DRY principle**: Eliminates duplication (e.g., `is_windows()`)
- **Clean APIs**: Simple, documented functions

#### Why Hesitate

- **Less unique**: Many similar utility libs exist (`plenary.nvim`, etc.)
- **May be over-engineering**: Vim's stdlib covers some of this
- **Best as internal library**: Unless you create a suite of plugins

#### Recommendation

**Keep internal** unless you build multiple plugins that share these utilities. If extracted, position as "Yoda plugin SDK" or "Yoda stdlib."

**Alternative:** Extract only the most unique parts (e.g., `cache.lua` if it has novel functionality).

---

### 5. **`yoda-diagnostics.nvim`** ⭐⭐⭐

**Location:** `lua/yoda/diagnostics/`  
**Files:** `lsp.lua`, `ai.lua`, `composite.lua`, `init.lua`  
**LOC:** ~400 lines  
**Test Coverage:** Good

#### Why Extract

- **Useful composite pattern**: Check multiple health systems at once
- **LSP + AI diagnostics**: Comprehensive system check
- **Good architecture**: Demonstrates GoF Composite pattern

#### Why Hesitate

- **Yoda-specific**: Checks Yoda's AI setup (OpenCode, Copilot), not generic
- **Niche use case**: Most users just use `:checkhealth`
- **Would need refactoring**: To make it generic for any config

#### Recommendation

**Option 1:** Refactor to be generic health-check framework:
```lua
local diagnostics = require("yoda-diagnostics")
diagnostics.register("my-plugin", {
  check = function() return true, "All good!" end
})
diagnostics.run_all()
```

**Option 2:** Keep Yoda-internal as distribution-specific diagnostics.

**Choose:** Option 2 (keep internal) unless you want to build a generic framework.

---

### 6. **`yoda-window.nvim`** ⭐⭐⭐

**Location:** `lua/yoda/window/`  
**Files:** `protection.lua`  
**LOC:** ~220 lines

#### Why Extract

- **Solves real problem**: Prevents buffer overwrites in explorer/special windows
- **Smart redirection**: Automatically finds/creates main editing window
- **Reasonable size**: ~220 LOC, well-structured

#### Why Hesitate

- **Snacks-specific**: Tailored to Snacks Explorer behavior
- **Edge case handling**: Complex autocmd logic
- **May not generalize well**: Different explorers have different behaviors

#### Recommendation

**Wait** until you support multiple explorers (nvim-tree, neo-tree, oil.nvim), then extract as generic "window protection" solution.

**Alternative:** Extract now as `yoda-window-protection.nvim` with explicit Snacks support, add other explorers later.

---

## 🚫 KEEP INTERNAL - Not Ready for Extraction

### 7. **DI Container** (`container.lua`)

**Why keep internal:**
- Yoda-specific wiring and service registration
- Hard to generalize without knowing consumer needs
- Better as pattern/template than standalone plugin
- Most Neovim configs don't need DI at this scale

**Alternative:** Write blog post or ADR explaining the pattern for others to copy.

---

### 8. **Config/YAML Parsers** (`config.lua`, `yaml_parser.lua`)

**Why keep internal:**
- Yoda-specific configuration structure
- Many other config solutions exist (neoconf.nvim, etc.)
- Best kept as part of the distribution
- YAML parser uses goto statements (intentional, but non-standard)

---

## 📦 Recommended Extraction Order

### Phase 1: Foundation (Month 1)

**1. Extract `yoda.nvim-adapters`**
- ✅ **Goal:** Standalone notification/picker adapter plugin
- ✅ **Actions:**
  - Create repo: `github.com/jedi-knights/yoda.nvim-adapters`
  - Copy files: `lua/yoda/adapters/*.lua`
  - Copy tests: `tests/unit/adapters/*_spec.lua`
  - Add CI workflow (GitHub Actions)
  - Write comprehensive README with examples
  - Publish v1.0.0
- ✅ **Update Yoda:** Change to external dependency in `lazy-plugins.lua`

### Phase 2: Domain-Specific (Month 2-3)

**2. Extract `yoda-logging.nvim`**
- ✅ **Goal:** Standalone logging framework
- ✅ **Dependencies:** Optional `yoda.nvim-adapters` for notify strategy
- ✅ **Actions:**
  - Create repo: `github.com/jedi-knights/yoda-logging.nvim`
  - Copy files: `lua/yoda/logging/*`
  - Copy tests: `tests/unit/logging/*_spec.lua`
  - Update imports to use external adapters
  - Add CI workflow
  - Write comprehensive README (already exists!)
  - Add examples: `examples/logging_usage.lua`
  - Publish v1.0.0

**3. Extract `yoda-terminal.nvim`**
- ✅ **Goal:** Python venv + terminal integration
- ✅ **Dependencies:** `yoda.nvim-adapters` (required for picker)
- ✅ **Actions:**
  - Create repo: `github.com/jedi-knights/yoda-terminal.nvim`
  - Copy files: `lua/yoda/terminal/*`
  - Copy tests: `tests/unit/terminal/*_spec.lua`
  - Update imports to use external adapters
  - Add CI workflow
  - Write README with Python-focused examples
  - Add demo GIF (venv selection in action)
  - Publish v1.0.0

### Phase 3: Evaluate Later (Month 4+)

**4. Consider `yoda-core.nvim`** (only if building plugin ecosystem)  
**5. Consider `yoda-diagnostics.nvim`** (after generic refactoring)  
**6. Consider `yoda-window.nvim`** (after multi-explorer support)

---

## 💡 Benefits of Extraction

### For the Community

| Benefit | Description |
|---------|-------------|
| **Reusable components** | Other configs benefit from your work |
| **Testing ground** | Get feedback on API design from wider audience |
| **Portfolio pieces** | Demonstrate software engineering skills (SOLID, GoF patterns) |
| **Collaboration** | Others contribute improvements, bug fixes, new features |
| **Discoverability** | Separate repos are easier to find and star |

### For Yoda.nvim

| Benefit | Description |
|---------|-------------|
| **Modularity** | Easier to maintain separate concerns |
| **Versioning** | Lock to stable plugin versions (semantic versioning) |
| **Documentation** | Each plugin gets dedicated docs/examples |
| **Quality signals** | Individual plugins can be starred/tracked separately |
| **Reduced complexity** | Smaller core codebase, clearer boundaries |
| **Testability** | Plugins can be tested in isolation |

### For Your Personal Brand

| Benefit | Description |
|---------|-------------|
| **Credibility** | Multiple quality plugins show expertise |
| **Visibility** | More repos = more GitHub profile activity |
| **Learning** | Experience with plugin publishing, semver, etc. |
| **Feedback loop** | Community usage reveals what works/doesn't |

---

## 🚀 Next Steps

### If You Want to Proceed

#### Step 1: Extract `yoda.nvim-adapters` (Foundational)

```bash
# Create new repository
mkdir -p ~/src/github/jedi-knights/yoda.nvim-adapters
cd ~/src/github/jedi-knights/yoda.nvim-adapters
git init

# Copy files
mkdir -p lua/yoda-adapters tests/unit
cp ~/src/github/jedi-knights/yoda.nvim/lua/yoda/adapters/*.lua lua/yoda-adapters/
cp -r ~/src/github/jedi-knights/yoda.nvim/tests/unit/adapters tests/unit/

# Update require() paths in copied files:
# require("yoda.adapters.notification") → require("yoda-adapters.notification")

# Copy CI, tests, README template
cp ~/src/github/jedi-knights/yoda.nvim/.github/workflows/ci.yml .github/workflows/
cp ~/src/github/jedi-knights/yoda.nvim/stylua.toml .
cp ~/src/github/jedi-knights/yoda.nvim/tests/helpers.lua tests/

# Create README.md with:
# - Installation instructions (Lazy.nvim)
# - Usage examples
# - API documentation
# - Backend support matrix
# - Contributing guidelines

# Initial commit
git add .
git commit -m "feat: initial release of yoda.nvim-adapters

- Notification adapter (noice, snacks, native)
- Picker adapter (snacks, telescope, native)
- Auto-detection with user override
- Comprehensive test coverage (~95%)
- Zero external dependencies"

# Push to GitHub
gh repo create jedi-knights/yoda.nvim-adapters --public --source=. --remote=origin
git push -u origin main

# Tag v1.0.0
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0
```

#### Step 2: Update Yoda.nvim to Use External Plugin

```lua
-- In lazy-plugins.lua, add:
{
  "jedi-knights/yoda.nvim-adapters",
  lazy = false,
  priority = 1000,  -- Load early (other plugins depend on it)
}

-- Update all require() calls:
-- OLD: require("yoda.adapters.notification")
-- NEW: require("yoda-adapters.notification")
```

#### Step 3: Document the Pattern

Create ADR (Architecture Decision Record):

```markdown
# ADR-008: Extract Adapters to Standalone Plugin

## Context
The adapter modules (notification, picker) are generic, well-tested, and useful
beyond Yoda.nvim. Extracting them benefits the community and improves modularity.

## Decision
Extract `lua/yoda/adapters/` to `jedi-knights/yoda.nvim-adapters`.

## Consequences
- ✅ Community can use adapters in any config
- ✅ Yoda depends on external, versioned plugin
- ✅ Adapters get separate issue tracking
- ⚠️ Breaking change for direct users of Yoda modules
```

#### Step 4: Marketing & Outreach

- **Reddit:** Post to r/neovim about the new plugin
- **Twitter/Mastodon:** Announce with code examples
- **awesome-neovim:** Submit PR to add plugin
- **Dotfyle:** Register plugin at dotfyle.com

---

## 📋 Checklist for Each Extraction

- [ ] Create new GitHub repository
- [ ] Copy source files with updated require() paths
- [ ] Copy test files and test infrastructure
- [ ] Copy CI workflow (GitHub Actions)
- [ ] Write comprehensive README:
  - [ ] Installation instructions (Lazy.nvim, Packer, etc.)
  - [ ] Quick start examples
  - [ ] Full API documentation
  - [ ] Configuration options
  - [ ] Troubleshooting section
  - [ ] Contributing guidelines
- [ ] Add LICENSE file (MIT)
- [ ] Add CHANGELOG.md
- [ ] Update Yoda.nvim:
  - [ ] Add plugin as dependency
  - [ ] Update all require() paths
  - [ ] Update documentation
  - [ ] Create ADR documenting extraction
- [ ] Test thoroughly:
  - [ ] Run plugin tests in isolation
  - [ ] Test Yoda.nvim with external dependency
  - [ ] Test with different backends (noice, snacks, etc.)
- [ ] Tag initial release (v1.0.0)
- [ ] Announce to community:
  - [ ] Reddit post
  - [ ] Twitter/Mastodon
  - [ ] awesome-neovim PR
  - [ ] Dotfyle registration

---

## 🎓 Lessons Learned from Analysis

### What Makes a Good Plugin Candidate?

✅ **High cohesion**: Module has single, clear purpose  
✅ **Low coupling**: Minimal dependencies on parent project  
✅ **Generic value**: Useful beyond specific use case  
✅ **Well-tested**: High coverage, easy to verify  
✅ **Documented**: Clear API, examples exist  
✅ **Stable**: Not rapidly changing, mature code  

### What Should Stay Internal?

❌ **Project-specific logic**: Tightly coupled to Yoda  
❌ **Immature code**: Still changing frequently  
❌ **Duplicate solutions**: Already exists elsewhere  
❌ **Tiny utilities**: Too small to justify separate plugin  
❌ **Configuration**: Project-specific settings  

---

## 🔗 Resources

- [Semantic Versioning](https://semver.org/) - Version numbering guide
- [Conventional Commits](https://www.conventionalcommits.org/) - Commit message format
- [Lazy.nvim Plugin Spec](https://github.com/folke/lazy.nvim#-plugin-spec) - Dependency management
- [awesome-neovim](https://github.com/rockerBOO/awesome-neovim) - Plugin directory
- [Dotfyle](https://dotfyle.com/) - Neovim plugin discovery

---

## 📞 Questions?

If you have questions about extraction strategy:
- Open GitHub Discussion in Yoda.nvim repo
- Review existing ADRs in `docs/adr/`
- Check `CONTRIBUTING.md` for general guidelines

---

**Good luck with the extractions! 🚀**

*May the Force be with you as you modularize your code.*
