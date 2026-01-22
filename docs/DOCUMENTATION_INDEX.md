# Documentation Index

**Complete guide to Yoda.nvim documentation**

---

## 🚀 Getting Started (5 minutes)

**New to Yoda.nvim?** Start here:

1. **[README.md](../README.md)** - Project overview and quick install
2. **[QUICK_START.md](QUICK_START.md)** - ⭐ **NEW!** Get contributing in 5 minutes
3. **[GETTING_STARTED.md](GETTING_STARTED.md)** - Learn the basics

---

## 👤 For Users

### Installation & Setup
- **[README.md](../README.md)** - Quick installation
- **[GETTING_STARTED.md](GETTING_STARTED.md)** - First steps with Yoda.nvim
- **[KEYMAPS.md](KEYMAPS.md)** - Complete keymap reference

### Configuration
- **[USER_CONFIGURATION.md](USER_CONFIGURATION.md)** - ⭐ **NEW!** Customize terminal, YAML, and more
- **[CONFIGURATION.md](CONFIGURATION.md)** - General configuration guide
- **[AI_SETUP.md](AI_SETUP.md)** - Configure Copilot and OpenCode integration

### Troubleshooting
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions
- **[PERFORMANCE_GUIDE.md](PERFORMANCE_GUIDE.md)** - Optimize performance

### Features
- **[FEATURES.md](FEATURES.md)** - Complete feature list
- **[SESSION_MANAGEMENT.md](SESSION_MANAGEMENT.md)** - Session persistence
- **[INTERACTIVE_TUTORIALS.md](INTERACTIVE_TUTORIALS.md)** - Built-in tutorials

---

## 🛠️ For Contributors

### Getting Started
- **[QUICK_START.md](QUICK_START.md)** - ⭐ **NEW!** 5-minute contributor onboarding
- **[CONTRIBUTING.md](../CONTRIBUTING.md)** - Complete contribution guide
- **[STANDARDS_QUICK_REFERENCE.md](STANDARDS_QUICK_REFERENCE.md)** - Code quality standards

### Architecture
- **[diagrams/ARCHITECTURE.md](diagrams/ARCHITECTURE.md)** - ⭐ **NEW!** Visual architecture guide
  - Dependency hierarchy diagrams
  - Design pattern visualizations  
  - Data flow diagrams
  - Module organization
- **[DESIGN_PATTERNS.md](DESIGN_PATTERNS.md)** - Gang of Four patterns used
- **[DEPENDENCY_INJECTION.md](DEPENDENCY_INJECTION.md)** - DI container guide

### Code Quality
- **[STANDARDS_QUICK_REFERENCE.md](STANDARDS_QUICK_REFERENCE.md)** - All standards in one place
  - SOLID principles (S, O, L, I, D)
  - DRY principles
  - CLEAN code principles (C, L, E, A, N)
  - Cyclomatic complexity guidelines
- **[START_HERE.md](START_HERE.md)** - Code quality achievement story (5.8 → 15/15)

### Testing
- **[tests/README.md](../tests/README.md)** - Testing guide (if exists)
- Test files mirror `lua/` structure in `tests/unit/`
- 302 tests, ~95% coverage

---

## 🧑‍💻 For Developers

### Language-Specific
- **[javascript_development.md](javascript_development.md)** - JavaScript/TypeScript setup
- **[PYTHON_DEBUGGING.md](PYTHON_DEBUGGING.md)** - Python debugging with DAP

### Advanced Topics
- **[overview/LSP.md](overview/LSP.md)** - Language Server Protocol
- **[overview/DAP.md](overview/DAP.md)** - Debug Adapter Protocol
- **[overview/DEBUGGING.md](overview/DEBUGGING.md)** - Debugging guide
- **[overview/HARPOON.md](overview/HARPOON.md)** - File navigation with Harpoon

### Integration Guides
- **[OPENCODE.md](OPENCODE.md)** - OpenCode AI integration
- **[OPENCODE_PERMISSIONS.md](OPENCODE_PERMISSIONS.md)** - OpenCode permissions setup
- **[guides/NOICE_COMPATIBILITY.md](guides/NOICE_COMPATIBILITY.md)** - Noice.nvim integration
- **[PREPROCESSOR_INTEGRATION.md](PREPROCESSOR_INTEGRATION.md)** - Preprocessor setup

---

## 📐 Architecture Deep Dives

### Performance
- **[PERFORMANCE_GUIDE.md](PERFORMANCE_GUIDE.md)** - General performance guide
- **[PERFORMANCE_OPTIMIZATION_COMPLETE.md](PERFORMANCE_OPTIMIZATION_COMPLETE.md)** - Complete optimization
- **[PHASE1_AUTOCMD_OPTIMIZATION_SUMMARY.md](PHASE1_AUTOCMD_OPTIMIZATION_SUMMARY.md)** - Autocmd optimization
- **[PHASE2_LSP_OPTIMIZATION_SUMMARY.md](PHASE2_LSP_OPTIMIZATION_SUMMARY.md)** - LSP optimization
- **[PYTHON_LSP_OPTIMIZATION.md](PYTHON_LSP_OPTIMIZATION.md)** - Python LSP performance

### Refactoring History
- **[refactoring/GLOBAL_CONFIG_REFACTOR.md](refactoring/GLOBAL_CONFIG_REFACTOR.md)** - Config refactoring
- **[BUFENTER_DEBOUNCING_ANALYSIS.md](BUFENTER_DEBOUNCING_ANALYSIS.md)** - Event debouncing
- **[PYTHON_FLICKERING_FIX.md](PYTHON_FLICKERING_FIX.md)** - Python flickering fix

### System Integration
- **[AUTOCMDS.md](AUTOCMDS.md)** - Autocommand system
- **[AUTO_UPDATE_CONFIG.md](AUTO_UPDATE_CONFIG.md)** - Auto-update configuration
- **[LARGE_FILE_HANDLING.md](LARGE_FILE_HANDLING.md)** - Large file optimization

---

## 🎓 Learning Resources

### Tutorials & Guides
- **[guides/VIM_TUTOR.md](guides/VIM_TUTOR.md)** - Vim basics tutorial
- **[overview/vim-cheatsheet.md](overview/vim-cheatsheet.md)** - Vim command reference
- **[guides/TOOL_INDICATORS.md](guides/TOOL_INDICATORS.md)** - Tool indicator setup
- **[guides/WARP_ICON_SETUP.md](guides/WARP_ICON_SETUP.md)** - Warp terminal icon setup

### AI & ChatGPT
- **[overview/CHATGPT.md](overview/CHATGPT.md)** - ChatGPT integration
- **[AI_SETUP.md](AI_SETUP.md)** - AI tooling setup
- **[LLM_Prompt.txt](LLM_Prompt.txt)** - LLM prompts

---

## 📋 Reference

### Architecture Decision Records (ADRs)
- **[adr/0001-create-custom-neovim-distribution.md](adr/0001-create-custom-neovim-distribution.md)**
- **[adr/0002-adopt-conventional-commits.md](adr/0002-adopt-conventional-commits.md)**
- **[adr/0003-use-lazy-package-manager.md](adr/0003-use-lazy-package-manager.md)**
- **[adr/0004-use-tokyonight-colorscheme.md](adr/0004-use-tokyonight-colorscheme.md)**
- **[adr/0005-use-nvim-tree.md](adr/0005-use-nvim-tree.md)**
- **[adr/0006-use-editorconfig-plugin.md](adr/0006-use-editorconfig-plugin.md)**
- **[adr/0007-gang-of-four-design-patterns.md](adr/0007-gang-of-four-design-patterns.md)**

### Module Documentation
- **[overview/FUNCTIONS.md](overview/FUNCTIONS.md)** - Core functions reference

---

## 🎯 Quick Links by Task

### I want to...

**Install Yoda.nvim**
→ [README.md](../README.md) → [GETTING_STARTED.md](GETTING_STARTED.md)

**Customize terminal size/appearance**
→ [USER_CONFIGURATION.md](USER_CONFIGURATION.md) (Terminal section)

**Add custom environments to YAML parser**
→ [USER_CONFIGURATION.md](USER_CONFIGURATION.md) (YAML section)

**Contribute code**
→ [QUICK_START.md](QUICK_START.md) → [STANDARDS_QUICK_REFERENCE.md](STANDARDS_QUICK_REFERENCE.md)

**Understand the architecture**
→ [diagrams/ARCHITECTURE.md](diagrams/ARCHITECTURE.md) → [DESIGN_PATTERNS.md](DESIGN_PATTERNS.md)

**Fix performance issues**
→ [PERFORMANCE_GUIDE.md](PERFORMANCE_GUIDE.md) → [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

**Set up Python debugging**
→ [PYTHON_DEBUGGING.md](PYTHON_DEBUGGING.md) → [overview/DAP.md](overview/DAP.md)

**Configure AI tools**
→ [AI_SETUP.md](AI_SETUP.md) → [OPENCODE.md](OPENCODE.md)

**Learn keymaps**
→ [KEYMAPS.md](KEYMAPS.md) → [guides/VIM_TUTOR.md](guides/VIM_TUTOR.md)

**Report a bug**
→ [TROUBLESHOOTING.md](TROUBLESHOOTING.md) → [GitHub Issues](https://github.com/jedi-knights/yoda.nvim/issues)

---

## 📊 Documentation Stats

- **Total Documents**: 50+
- **New Documents (Latest)**: 3
  - `QUICK_START.md` - 5-minute contributor guide
  - `diagrams/ARCHITECTURE.md` - Visual architecture
  - `USER_CONFIGURATION.md` - User customization guide
- **Code Quality**: 15/15 (Perfect)
- **Test Coverage**: ~95% (302 tests)

---

## 🗺️ Documentation Map

```
docs/
├── 🚀 Getting Started
│   ├── README.md (root)
│   ├── QUICK_START.md ⭐ NEW
│   ├── GETTING_STARTED.md
│   └── KEYMAPS.md
│
├── ⚙️ Configuration
│   ├── USER_CONFIGURATION.md ⭐ NEW
│   ├── CONFIGURATION.md
│   └── AI_SETUP.md
│
├── 🏗️ Architecture
│   ├── diagrams/ARCHITECTURE.md ⭐ NEW
│   ├── DESIGN_PATTERNS.md
│   ├── DEPENDENCY_INJECTION.md
│   └── STANDARDS_QUICK_REFERENCE.md
│
├── 🧪 Development
│   ├── CONTRIBUTING.md (root)
│   ├── QUICK_START.md
│   └── STANDARDS_QUICK_REFERENCE.md
│
├── 🐛 Troubleshooting
│   ├── TROUBLESHOOTING.md
│   ├── PERFORMANCE_GUIDE.md
│   └── PYTHON_FLICKERING_FIX.md
│
├── 📚 Guides
│   ├── guides/ (tutorials)
│   ├── overview/ (deep dives)
│   └── adr/ (architecture decisions)
│
└── 🔧 Reference
    ├── Language-specific
    ├── Integration guides
    └── Advanced topics
```

---

## 🤝 Contributing to Documentation

Found outdated docs? Want to improve something?

1. **Minor fixes**: Submit a PR directly
2. **New documentation**: Open an issue first to discuss
3. **Follow style**: Match existing document formatting
4. **Add to index**: Update this file with new docs

**Guidelines:**
- Use clear, concise language
- Include code examples
- Add diagrams where helpful
- Cross-reference related docs
- Test all commands/examples

---

## 📝 Documentation Standards

**File Naming:**
- Use `SCREAMING_SNAKE_CASE.md` for major docs
- Use `lowercase_with_underscores.md` for subdirectories
- Use descriptive names (not `doc1.md`)

**Structure:**
- Start with title and brief description
- Use clear headings (H2, H3)
- Include code examples
- Add "See also" links at bottom
- Use emoji sparingly (mainly for sections)

**Content:**
- Write for beginners first
- Progressive disclosure (simple → advanced)
- Show, don't just tell (examples!)
- Keep it current (review regularly)

---

## 🎓 Learning Paths

### New User Path
1. [README.md](../README.md) - Overview
2. [GETTING_STARTED.md](GETTING_STARTED.md) - Basics
3. [KEYMAPS.md](KEYMAPS.md) - Keybindings
4. [USER_CONFIGURATION.md](USER_CONFIGURATION.md) - Customization

### New Contributor Path
1. [QUICK_START.md](QUICK_START.md) - Setup
2. [diagrams/ARCHITECTURE.md](diagrams/ARCHITECTURE.md) - Architecture
3. [STANDARDS_QUICK_REFERENCE.md](STANDARDS_QUICK_REFERENCE.md) - Standards
4. [CONTRIBUTING.md](../CONTRIBUTING.md) - Guidelines

### Developer Path
1. [DESIGN_PATTERNS.md](DESIGN_PATTERNS.md) - Patterns
2. [DEPENDENCY_INJECTION.md](DEPENDENCY_INJECTION.md) - DI
3. [overview/LSP.md](overview/LSP.md) - LSP setup
4. Language-specific guides

---

## 🔍 Search Tips

**By Topic:**
- Architecture → `diagrams/`, `DESIGN_PATTERNS.md`, `DEPENDENCY_INJECTION.md`
- Configuration → `USER_CONFIGURATION.md`, `CONFIGURATION.md`, `AI_SETUP.md`
- Performance → `PERFORMANCE_GUIDE.md`, `PHASE1_*`, `PHASE2_*`
- Testing → `QUICK_START.md`, `tests/`, code standards docs

**By Audience:**
- Users → Configuration, Features, Troubleshooting
- Contributors → QUICK_START, Standards, Architecture
- Developers → LSP, DAP, Language-specific

---

## 📬 Feedback

Found an issue with documentation?
- **Quick fix**: Submit a PR
- **Discussion needed**: Open an issue
- **Question**: GitHub Discussions

---

> "Much to learn, you still have." - Yoda

Happy reading! 📚 May the docs be with you! ⚡
