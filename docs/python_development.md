# Python Development in Yoda.nvim

> A comprehensive guide to Python development in Yoda.nvim with basedpyright LSP, debugpy debugging, ruff/mypy linting, and neotest integration.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [LSP Features](#lsp-features)
4. [Debugging](#debugging)
5. [Testing](#testing)
6. [Virtual Environments](#virtual-environments)
7. [Linting & Formatting](#linting--formatting)
8. [Type Checking](#type-checking)
9. [REPL](#repl)
10. [Code Navigation](#code-navigation)
11. [Keymap Reference](#keymap-reference)
12. [Troubleshooting](#troubleshooting)

---

## Quick Start

### 1. Install Python Tools

Run the setup command to install all required tools:

```vim
:YodaPythonSetup
```

This installs:
- `basedpyright` - LSP server (modern, fast fork of pyright)
- `debugpy` - Debug adapter
- `ruff` - Linter/formatter (ultra-fast)

After installation completes, restart Neovim.

### 2. Open a Python Project

```bash
cd your-python-project
nvim main.py
```

basedpyright will automatically activate and provide:
- ✅ Code completion
- ✅ Type checking
- ✅ Auto-imports
- ✅ Inline diagnostics
- ✅ Refactoring actions

### 3. Essential Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>pr` | Run Python file |
| `<leader>pi` | Open Python REPL |
| `<leader>pt` | Run nearest test |
| `<leader>pd` | Debug test |
| `<leader>pv` | Select virtual environment |
| `<leader>po` | Toggle outline |

---

## Installation

### Automatic Setup

```vim
:YodaPythonSetup
```

This command installs all necessary tools via Mason.

### Manual Setup

If you prefer manual installation:

#### 1. Install basedpyright

**Via Mason (Recommended):**
```vim
:Mason
# Navigate to basedpyright, press 'i' to install
```

**Via npm:**
```bash
npm install -g @basedpyright/pyright
```

#### 2. Install debugpy (Debugger)

**Via Mason (Recommended):**
```vim
:Mason
# Navigate to debugpy, press 'i' to install
```

**Via pip:**
```bash
pip install debugpy
```

**Note**: Install debugpy in each virtual environment you want to debug.

#### 3. Install ruff (Linter/Formatter)

**Via Mason (Recommended):**
```vim
:Mason
# Navigate to ruff, press 'i' to install
```

**Via pip:**
```bash
pip install ruff
```

#### 4. Restart Neovim

After installation, restart Neovim to activate the tools.

### Verify Installation

Open a Python file and check:
```vim
:LspInfo        " Should show basedpyright attached
:Mason          " Should show basedpyright, debugpy, and ruff installed
```

---

## LSP Features

Yoda.nvim uses `basedpyright` for Python LSP support.

### Why basedpyright?

- ⚡ **Faster** than pyright
- 🎯 **Better type inference**
- 🔧 **Community-maintained** fork
- ✅ **Drop-in replacement** for pyright

### Code Completion

Automatic as you type. Powered by basedpyright and Neovim's built-in LSP.

Features:
- Function/method completions
- Module imports
- Type hints
- Docstring snippets

### Go to Definition

| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |

### Auto-Imports

basedpyright automatically suggests and adds imports:

```python
# Type: Path
# basedpyright suggests: from pathlib import Path
```

Press `<CR>` to accept the auto-import.

### Type Checking

basedpyright provides real-time type checking:

```python
def greet(name: str) -> str:
    return f"Hello, {name}"

greet(123)  # ⚠️ Error: Expected str, got int
```

Configure type checking strictness in LSP settings:
- `"off"` - No type checking
- `"basic"` - Basic type checking (default)
- `"strict"` - Strict type checking

### Code Actions

| Keymap | Action |
|--------|--------|
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |

Available code actions:
- Add missing imports
- Add type annotations
- Extract variable/function
- Remove unused imports
- Organize imports

---

## Debugging

Yoda.nvim integrates `debugpy` for Python debugging via `nvim-dap`.

### Setup Debugging

1. Ensure debugpy is installed (`:Mason` or in your venv)
2. Open a Python file
3. Set breakpoints
4. Start debugging

### Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>pd` | Debug nearest test (pytest) |
| `<leader>pD` | Debug test class |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / Start debug |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>dO` | Step out |
| `<leader>dq` | Terminate debug session |
| `<leader>du` | Toggle DAP UI |

### Debugging Workflow

1. **Set breakpoint**: Place cursor on line, press `<leader>db`
2. **Start debugger**: 
   - For tests: `<leader>pd` (debug nearest test)
   - For scripts: `<leader>dc` (continue/start)
3. **Control execution**:
   - `<leader>dc` - Continue
   - `<leader>do` - Step over
   - `<leader>di` - Step into
4. **Inspect variables**: Check DAP UI panels
5. **Stop**: `<leader>dq`

### Debug Configurations

nvim-dap-python provides several debug configurations:

- **Launch file** - Debug current file
- **Launch file with arguments** - Debug with command-line args
- **Debug test** - Debug pytest test
- **Attach to process** - Attach to running Python process

### Virtual Environment Detection

debugpy automatically uses the Python from your activated virtual environment.

Priority order:
1. venv-selector selected environment
2. `.venv` in current directory
3. `venv` in current directory
4. System Python

---

## Testing

Yoda.nvim uses `neotest-python` for running Python tests.

### Supported Test Frameworks

- ✅ **pytest** (recommended, default)
- ✅ **unittest**
- ✅ **nose2**

### Run Tests

| Keymap | Action |
|--------|--------|
| `<leader>pt` | Run nearest test |
| `<leader>pT` | Run all tests in file |
| `<leader>pC` | Run test suite |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Toggle test output |

### Test Workflow

1. **Write a test**:
```python
def test_addition():
    assert 2 + 2 == 4
```

2. **Run test**: Place cursor in test function, press `<leader>pt`

3. **View results**: 
   - Inline icons show pass/fail
   - `<leader>ts` - Open summary panel
   - `<leader>to` - See detailed output

### Debug Tests

To debug a failing test:
1. Set breakpoint in test
2. Press `<leader>pd` - Debug nearest test
3. Use standard debug keymaps

### Advanced Pytest Picker

For complex test scenarios, use the advanced pytest picker:

```vim
<leader>tt      " Opens pytest picker
```

Features:
- Environment selection (qa, staging, prod)
- Region selection
- Marker filtering (`-m markers`)
- Allure report integration
- Virtual environment detection

### Virtual Environment Integration

neotest-python automatically detects and uses your virtual environment:

```python
# Automatically uses .venv/bin/python if available
pytest tests/
```

---

## Virtual Environments

Yoda.nvim provides excellent virtual environment support.

### Auto-Detection

Virtual environments are automatically detected in this order:

1. venv-selector selected environment
2. `.venv` in current directory
3. `venv` in current directory
4. `.env` in current directory
5. Parent directory `.venv`
6. System Python

### Manual Selection

Use venv-selector for visual environment selection:

```vim
<leader>pv      " Open venv selector UI
```

Or:
```vim
:VenvSelect     " Same as above
:YodaPythonVenv " Alias command
```

### venv-selector Features

- 🔍 **Auto-discover** virtual environments
- 📁 **Workspace search** for venvs
- 🎯 **Telescope integration** for fuzzy finding
- 🔄 **Auto-refresh** on directory changes
- 🐛 **DAP integration** (auto-configures debugpy)
- 📊 **Status indication** in statusline

### Creating Virtual Environments

```bash
# Python 3
python3 -m venv .venv

# Activate
source .venv/bin/activate  # Unix
.venv\Scripts\activate      # Windows

# Install dependencies
pip install -r requirements.txt

# Install debugpy for debugging
pip install debugpy
```

### Multiple Virtual Environments

If you have multiple venvs, venv-selector shows all:

```
Select Python Virtual Environment:
  › .venv         (Python 3.11.5)
    venv          (Python 3.10.2)
    env           (Python 3.9.7)
```

---

## Linting & Formatting

### Formatting

Yoda.nvim uses `conform.nvim` with **ruff** (preferred) and **black** (fallback).

**Auto-format on save**: Enabled by default

**Manual format**:
```vim
<leader>f       " Format buffer
```

#### Why ruff?

- ⚡ **10-100x faster** than black
- 🎯 **Drop-in replacement** for black
- 🔧 **Additional features** (import sorting, line length)

Configuration: Uses project's `pyproject.toml` or `ruff.toml` if present.

### Linting

Yoda.nvim uses `nvim-lint` with **ruff** and **mypy**.

#### Ruff (Fast Linter)

Replaces multiple tools:
- **flake8** - Style checking
- **pylint** - Code analysis
- **isort** - Import sorting
- **pyupgrade** - Python version upgrades

**When it runs**:
- On buffer enter
- On save
- On leaving insert mode

**View diagnostics**:
```vim
<leader>pe      " Open diagnostics in Trouble
```

#### Mypy (Type Checker)

Optional static type checker for Python:

**Manual run**:
```vim
<leader>pm      " Run mypy on current file
```

Or from terminal:
```bash
mypy your_file.py
```

**Configure mypy**: Create `mypy.ini` or use `pyproject.toml`:

```toml
[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
```

### Disable Format on Save

If you prefer manual formatting:

```lua
-- In ~/.config/nvim/lua/local.lua
vim.g.conform_autoformat = false
```

---

## Type Checking

### basedpyright Type Checking

basedpyright provides real-time type checking as you type.

**Type checking modes**:
- `off` - No type checking
- `basic` - Basic type checking (default)
- `strict` - Strict type checking

**Change mode** (edit `lua/yoda/lsp.lua`):
```lua
vim.lsp.config.basedpyright = {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "strict",  -- Change here
      },
    },
  },
}
```

### Type Hints Best Practices

```python
from typing import List, Dict, Optional, Union

def process_data(
    items: List[str],
    config: Dict[str, int],
    optional_param: Optional[str] = None
) -> Union[int, str]:
    """
    Process data with type hints.
    
    Args:
        items: List of strings to process
        config: Configuration dictionary
        optional_param: Optional parameter
        
    Returns:
        Processed result as int or str
    """
    pass
```

### mypy Integration

For stricter type checking, use mypy alongside basedpyright:

```vim
<leader>pm      " Run mypy on current file
```

mypy catches more edge cases:
```python
def add(a: int, b: int) -> int:
    return a + b

result = add("1", "2")  # mypy error: Argument has incompatible type "str"
```

---

## REPL

### Interactive Python Shell

Open an interactive Python REPL:

```vim
<leader>pi      " Open Python REPL in floating terminal
```

Or (alternative keymap):
```vim
<leader>vr      " Python REPL (same as above)
```

### Features

- ✅ **Virtual environment aware** - Uses active venv
- ✅ **Floating terminal** - Doesn't split your layout
- ✅ **Persistent** - Toggle on/off with same keymap
- ✅ **Interactive** - Full REPL functionality

### REPL Workflow

```vim
<leader>pi      " Open REPL

# In REPL:
>>> import numpy as np
>>> arr = np.array([1, 2, 3])
>>> arr * 2
array([2, 4, 6])

<leader>pi      " Toggle off (close REPL)
```

### Advanced REPL

For more advanced features, consider:
- **IPython**: `pip install ipython`
- **bpython**: `pip install bpython`

Then update REPL command to use your preferred shell.

---

## Code Navigation

### Outline View (Aerial)

View code structure with `aerial.nvim`.

**Toggle outline**:
```vim
<leader>po      " Toggle outline sidebar
```

Shows:
- Functions
- Classes
- Methods
- Variables
- Imports

**Navigate**:
- Press `Enter` on symbol to jump
- `q` to close

### Symbol Search

**Document symbols**:
```vim
<leader>fR      " Find symbols in current file
```

**Workspace symbols**:
```vim
<leader>fS      " Find symbols across project
```

### File Navigation

**Find files** (Snacks picker):
```vim
<leader>ff      " Find files
<leader>fg      " Grep in files
<leader>fr      " Recent files
```

**Git files** (Telescope):
```vim
<leader>fG      " Find Git files
```

---

## Keymap Reference

### Python-Specific Keymaps

All Python keymaps use the `<leader>p` prefix.

#### Execution

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>pr` | Run Python file | Native |
| `<leader>pi` | Open Python REPL | Snacks terminal |

#### Testing

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>pt` | Run nearest test | Neotest |
| `<leader>pT` | Run file tests | Neotest |
| `<leader>pC` | Run test suite | Neotest |

#### Debugging

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>pd` | Debug test method | dap-python |
| `<leader>pD` | Debug test class | dap-python |
| `<leader>db` | Toggle breakpoint | DAP |
| `<leader>dc` | Continue | DAP |

#### Virtual Environments

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>pv` | Select venv | venv-selector |

#### Navigation

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>po` | Toggle outline | Aerial |
| `<leader>fR` | Find symbols | Telescope |

#### Diagnostics & Quality

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>pe` | Open diagnostics | Trouble |
| `<leader>pm` | Run mypy | mypy |
| `<leader>pc` | Show coverage | nvim-coverage |

### General LSP Keymaps

| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>f` | Format buffer |

### Advanced Testing

| Keymap | Action |
|--------|--------|
| `<leader>tt` | Advanced pytest picker (environment, markers) |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Toggle test output |
| `<leader>td` | Debug nearest test |

---

## Troubleshooting

### basedpyright not starting

**Check installation**:
```vim
:Mason          " Verify basedpyright is installed
:LspInfo        " Check if attached to buffer
```

**Reinstall**:
```vim
:MasonUninstall basedpyright
:MasonInstall basedpyright
```

**Restart LSP**:
```vim
:LspRestart
```

**Check for errors**:
```vim
:LspLog         " View LSP logs
```

### Import errors / Module not found

**Check virtual environment**:
```vim
<leader>pv      " Verify correct venv is selected
```

**Ensure packages installed**:
```bash
# Activate venv
source .venv/bin/activate

# Install packages
pip install -r requirements.txt
```

**Restart LSP** after installing packages:
```vim
:LspRestart
```

### Debugger not working

**Check debugpy installation**:
```vim
:Mason          " Verify debugpy installed
```

**Install in virtual environment**:
```bash
source .venv/bin/activate
pip install debugpy
```

**Check DAP configuration**:
```vim
:lua print(vim.inspect(require("dap").configurations.python))
```

**Restart Neovim** after installing debugpy.

### Tests not detected

**Check pytest installation**:
```bash
source .venv/bin/activate
pip install pytest
```

**Check test file naming**:
- Files: `test_*.py` or `*_test.py`
- Functions: `def test_*()`
- Classes: `class Test*`

**Restart neotest**:
```vim
:Neotest run.run()
```

### Virtual environment not detected

**Check venv location**:
```bash
ls -la .venv/    # Should exist
```

**Create if missing**:
```bash
python3 -m venv .venv
```

**Manual selection**:
```vim
<leader>pv      " Manually select venv
```

### Ruff not linting

**Check ruff installation**:
```vim
:Mason          " Verify ruff installed
```

**Or install via pip**:
```bash
pip install ruff
```

**Check nvim-lint**:
```vim
:lua print(vim.inspect(require("lint").linters_by_ft.python))
```

### Type checking too strict/loose

**Adjust basedpyright mode** (edit `lua/yoda/lsp.lua`):
```lua
typeCheckingMode = "basic",  -- Change to "off" or "strict"
```

**Or use inline comments**:
```python
# type: ignore  - Ignore this line
```

---

## Best Practices

### 1. Use Type Hints

Always add type hints for better IDE support:

```python
def calculate_total(items: list[dict], tax_rate: float) -> float:
    """Calculate total with tax."""
    pass
```

### 2. Virtual Environments

Always use virtual environments:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 3. Test-Driven Development

Write tests first, use `<leader>pt` to run them as you code.

### 4. Format on Save

Keep format-on-save enabled for consistent code style.

### 5. Use REPL for Experimentation

Quick experiments:
```vim
<leader>pi      " Open REPL
>>> import requests
>>> requests.get("https://api.github.com").status_code
200
```

### 6. Leverage Code Actions

Press `<leader>ca` frequently to:
- Add missing imports
- Add type hints
- Extract functions
- Organize imports

### 7. Use Outline for Navigation

In large files, `<leader>po` provides quick navigation to functions/classes.

---

## Advanced Configuration

### Custom basedpyright Settings

Edit `lua/yoda/lsp.lua`:

```lua
vim.lsp.config.basedpyright = {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "strict",  -- More strict checking
        autoImportCompletions = true,
        useLibraryCodeForTypes = true,
        diagnosticSeverityOverrides = {
          reportUnusedVariable = "warning",
          reportUnusedImport = "information",
        },
      },
    },
  },
}
```

### Custom Ruff Rules

Create `pyproject.toml`:

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP"]
ignore = ["E501"]  # Line too long
```

### Custom Pytest Configuration

Create `pytest.ini`:

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
markers =
    slow: marks tests as slow
    integration: marks tests as integration
```

---

## Comparison with Other Editors

### vs VSCode

| Feature | Yoda.nvim | VSCode |
|---------|-----------|--------|
| LSP | basedpyright | Pylance |
| Speed | ⚡⚡⚡ Fast | ⚡⚡ Moderate |
| Memory | Low | High |
| Debugging | ✅ debugpy | ✅ debugpy |
| Testing | ✅ neotest | ✅ Test Explorer |
| Customization | ✅✅✅ Unlimited | ✅✅ Extensions |

### Advantages

- **Faster**: Lighter weight, quicker startup
- **Keyboard-driven**: No mouse needed
- **Terminal-based**: Works over SSH
- **Customizable**: Full Lua configuration
- **Unified**: Same editor for all languages

---

## Resources

### Official Documentation

- [Python Docs](https://docs.python.org/)
- [basedpyright](https://github.com/DetachHead/basedpyright)
- [ruff](https://docs.astral.sh/ruff/)
- [pytest](https://docs.pytest.org/)

### Plugin Documentation

- [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python)
- [neotest-python](https://github.com/nvim-neotest/neotest-python)
- [venv-selector.nvim](https://github.com/linux-cultist/venv-selector.nvim)

### Yoda.nvim Docs

- [LSP Guide](overview/LSP.md)
- [Debugging Guide](overview/DEBUGGING.md)
- [Keymaps Reference](KEYMAPS.md)
- [Troubleshooting](TROUBLESHOOTING.md)

---

## Feedback

Found an issue or have a suggestion? 

- [Open an issue](https://github.com/jedi-knights/yoda.nvim/issues)
- [Start a discussion](https://github.com/jedi-knights/yoda.nvim/discussions)

---

> *"Do. Or do not. There is no try."* — Yoda

Happy Python coding! 🐍

