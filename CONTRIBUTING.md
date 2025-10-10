# Contributing to Yoda.nvim

First, thank you for considering contributing! 🎉  
This project is designed to grow alongside its users — so whether you're learning, experimenting, or an experienced developer, your help is welcome.

---

## 📋 Code Quality Standards

Yoda.nvim maintains world-class code quality (10/10):
- **SOLID Principles**: All 5 principles applied
- **CLEAN Code**: Cohesive, Loosely coupled, Encapsulated, Assertive, Non-redundant
- **DRY**: Zero code duplication
- **Test Coverage**: 302 tests, ~95% coverage

**Please read our standards documentation:**
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - System architecture
- [STANDARDS_QUICK_REFERENCE.md](docs/STANDARDS_QUICK_REFERENCE.md) - Code standards (SOLID/DRY/CLEAN/Complexity)
- [TESTING_GUIDE.md](docs/TESTING_GUIDE.md) - Testing guidelines

---

## 🔧 Development Setup

### Prerequisites

- **Neovim 0.10.1+**
- **Git**
- **StyLua** (for code formatting): `cargo install stylua`
- **Make** (optional but recommended)

### Setup

```bash
# Clone the repository
git clone https://github.com/jedi-knights/yoda.nvim.git
cd yoda.nvim

# Run tests
make test

# Check code style
make lint

# Format code
make format
```

---

## 📝 Contribution Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

### 2. Make Changes

- **Follow existing code patterns** - See [ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **Maintain SOLID/CLEAN/DRY principles** - See [STANDARDS_QUICK_REFERENCE.md](docs/STANDARDS_QUICK_REFERENCE.md)
- **Add tests for new functionality** - Required!
- **Update documentation** if needed
- **Keep it beginner-friendly** - Clear, modular, easy to understand

### 3. Write Tests (Required!)

**All new code must have tests.** We maintain ~95% test coverage.

```bash
# Create test file
cp tests/unit/core/string_spec.lua tests/unit/your_module_spec.lua

# Edit tests
nvim tests/unit/your_module_spec.lua

# Run tests
make test
```

**Test Requirements:**
- ✅ Use AAA pattern (Arrange-Act-Assert)
- ✅ Test edge cases (nil, empty, errors)
- ✅ Achieve >90% coverage for new code
- ✅ All tests must pass

**Example test:**
```lua
describe("module_name", function()
  describe("function_name()", function()
    it("does what it should", function()
      -- Arrange
      local input = "test"
      
      -- Act
      local result = module.function_name(input)
      
      -- Assert
      assert.equals("expected", result)
    end)
  end)
end)
```

### 4. Format Code

```bash
# Format your changes
make format

# Verify formatting
make lint
```

### 5. Run All Checks

```bash
# Run the full CI suite locally
make lint && make test
```

**All checks must pass before submitting PR.**

### 6. Commit Changes

Use [Conventional Commits](https://www.conventionalcommits.org/) (Angular convention):

```bash
# Format: <type>(<scope>): <description>

git commit -m "feat(core): add new string utility function"
git commit -m "fix(adapters): fix notification backend detection"
git commit -m "test: add tests for window_utils module"
git commit -m "docs: update architecture documentation"
git commit -m "style: format code with stylua"
```

**Commit Types:**
- `feat`: New feature
- `fix`: Bug fix
- `test`: Adding/updating tests
- `docs`: Documentation changes
- `style`: Code style/formatting
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `chore`: Maintenance tasks

### 7. Push and Create PR

```bash
git push origin your-branch-name
```

Then create a Pull Request on GitHub.

---

## 🧪 Testing Guidelines

### Test Coverage Requirements

- **New modules**: >90% coverage
- **Modified functions**: 100% coverage of changes
- **Edge cases**: nil, empty, errors must be tested
- **Integration**: Test interactions between modules

### Running Tests

```bash
make test           # Run all 302 tests
make test-unit      # Run unit tests only
<leader>tt          # From Neovim: run current test file
<leader>ta          # From Neovim: run all tests
<leader>tw          # From Neovim: watch mode
```

### Test Helpers

Use the comprehensive test helpers in `tests/helpers.lua`:

```lua
local helpers = require("tests.helpers")

-- Spy on calls
local spy_fn, spy_data = helpers.spy()
helpers.assert_called(spy_data)

-- Mock functions
local restore = helpers.mock(obj, "method", function() end)
restore() -- Cleanup

-- Mock Neovim API
local api = helpers.mock_nvim_api()
```

---

## 🎨 Code Style

### Module Structure

```lua
-- lua/yoda/module_name.lua
-- Brief description

local M = {}

--- Function documentation
--- @param name type Description
--- @return type Description
function M.function_name(name)
  -- Input validation (assertive programming)
  if type(name) ~= "string" then
    vim.notify("name must be a string", vim.log.levels.ERROR)
    return nil
  end
  
  -- Implementation
end

return M
```

### Design Principles

**Single Responsibility:**
- Each module has one clear purpose
- Target <300 lines per file

**Input Validation:**
```lua
-- Validate all public function inputs
if type(param) ~= "string" or param == "" then
  vim.notify("error message", vim.log.levels.ERROR)
  return nil
end
```

**Consistent Error Handling:**
```lua
-- Use (boolean, result_or_error) pattern
local ok, result = pcall(risky_function)
if not ok then
  return false, "Error: " .. result
end
return true, result
```

**Dependency Inversion:**
```lua
-- Use adapters, not direct plugin calls
local notify = require("yoda.adapters.notification")
notify.notify(msg, "info")  -- Works with any backend!
```

---

## 🛠️ How to Contribute

### 🔧 Improve the Configuration
- Add, configure, or improve plugins
- Enhance startup performance
- Improve modularity

### 📚 Documentation Contributions
- Improve README, docs, or ADRs
- Expand tutorials, examples, or setup guides
- Clarify anything confusing to new users

### 🐛 Bug Reports and Fixes
- If something doesn't work, open an issue or PR
- Fix broken keymaps, plugin configs, or setup errors
- Add regression tests for bugs

### 💡 Suggest New Features
- Propose beginner-friendly enhancements
- Suggest additional plugins or LSP servers
- Improve AI integration features

---

## 📖 Documentation

### Update Documentation When:

- **Adding new features** → Update `docs/FEATURES.md`
- **Adding keymaps** → Update `docs/KEYMAPS.md`
- **Changing architecture** → Update `docs/ARCHITECTURE.md`
- **Adding configuration** → Update `docs/CONFIGURATION.md`

### Documentation Standards

- Use markdown
- Include code examples
- Keep it concise and clear
- Add to table of contents if applicable

---

## 🐛 Bug Reports

### Include:

1. **Description**: Clear description of the bug
2. **Steps to Reproduce**: Minimal steps to reproduce
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Environment**:
   - Neovim version: `nvim --version`
   - OS: macOS/Linux/Windows
   - Yoda.nvim version/commit

### Example:

```markdown
**Bug**: Notification adapter crashes on startup

**Steps to Reproduce:**
1. Start Neovim
2. Error appears immediately

**Expected:** No error
**Actual:** Error message "adapter is nil"

**Environment:**
- Neovim 0.10.1
- macOS 14.6
- Commit: abc123
```

---

## ✨ Feature Requests

### Include:

1. **Use Case**: Why do you need this?
2. **Proposed Solution**: How would it work?
3. **Alternatives**: Other approaches considered?
4. **Impact**: Who would benefit?

---

## 🔍 Code Review Process

### All PRs Must:

- ✅ Pass CI checks (lint + tests)
- ✅ Have tests for new code (>90% coverage)
- ✅ Follow code standards (SOLID/CLEAN/DRY)
- ✅ Use conventional commits
- ✅ Update documentation
- ✅ Have clear description

### CI Checks

Your PR will automatically run:
- **Lint Check**: Code style validation with stylua
- **Test Suite**: 302 tests on Neovim stable and nightly
- **Coverage**: Validate test coverage for changes

**All checks must pass for PR to be merged.**

---

## 🎯 Areas for Contribution

### High Priority
- Terminal module tests
- Integration tests
- Performance optimizations
- Bug fixes

### Medium Priority
- New utility functions
- Additional adapters
- Documentation improvements
- Example configurations

### Nice to Have
- UI enhancements
- Plugin integrations
- Tutorial content
- Video guides

---

## 📚 Resources

### Essential Reading
- [Architecture Guide](docs/ARCHITECTURE.md) - System design
- [Code Standards](docs/STANDARDS_QUICK_REFERENCE.md) - Quality guidelines
- [Testing Guide](docs/TESTING_GUIDE.md) - How to write tests
- [Getting Started](docs/GETTING_STARTED.md) - User guide

### Development
- [Testing Guide](docs/TESTING_GUIDE.md) - Test infrastructure and guide
- [Makefile](Makefile) - Development commands
- [Test Helpers](tests/helpers.lua) - Testing utilities

---

## 💬 Getting Help

- **Questions?** Open a [GitHub Discussion](https://github.com/jedi-knights/yoda.nvim/discussions)
- **Issues?** Check [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- **Bugs?** Search [existing issues](https://github.com/jedi-knights/yoda.nvim/issues)

---

## 🧠 A Note on Learning

**It's okay if you're learning along the way.**  

The project itself is built to **help people level up** while working with Neovim.  
Mistakes are part of learning — **don't be afraid to contribute!** 🚀

We maintain high code quality, but we're also here to help you learn and grow.

---

## ⚡ Quick Reference

| Task | Command |
|------|---------|
| Run tests | `make test` |
| Check style | `make lint` |
| Format code | `make format` |
| All checks | `make lint && make test` |
| Help | `make help` |

---

> "Train yourself to let go of everything you fear to lose." — Yoda

**Welcome to the Yoda.nvim community! May the Force be with you! ⚡**
