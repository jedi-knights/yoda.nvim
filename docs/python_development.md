# Python Development in Yoda.nvim

> A comprehensive guide to Python development in Yoda.nvim with basedpyright LSP, debugpy debugging, pytest/neotest testing, and ruff linting/formatting.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [LSP Features](#lsp-features)
4. [Debugging](#debugging)
5. [Testing](#testing)
6. [Virtual Environments](#virtual-environments)
7. [Linting & Formatting](#linting--formatting)
8. [Type Checking](#type-checking)
9. [Python REPL](#python-repl)
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
- `basedpyright` — LSP server (modern, fast fork of pyright)
- `debugpy` — Debug adapter for Python
- `ruff` — Ultra-fast linter and formatter

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
- ✅ Go to definition / references
- ✅ Hover documentation

### 3. Essential Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>pr` | Run Python file |
| `<leader>pi` | Open Python REPL |
| `<leader>pt` | Run nearest test |
| `<leader>pd` | Debug test method |
| `<leader>pv` | Select virtual environment |
| `<leader>po` | Toggle code outline |

---

## Installation

### Automatic Setup

```vim
:YodaPythonSetup
```

This command installs all necessary tools via Mason.

### Manual Setup

If you prefer manual installation:

#### 1. Install basedpyright (LSP)

**Via Mason (Recommended):**
```vim
:Mason
" Navigate to basedpyright, press 'i' to install
```

**Via pip:**
```bash
pip install basedpyright
```

**Note**: Yoda.nvim uses `basedpyright`, not `pyright`. Pyright is explicitly disabled to prevent conflicts.

#### 2. Install debugpy (Debugger)

**Via Mason (Recommended):**
```vim
:Mason
" Navigate to debugpy, press 'i' to install
```

**Via pip:**
```bash
pip install debugpy
```

#### 3. Install ruff (Linter/Formatter)

**Via Mason (Recommended):**
```vim
:Mason
" Navigate to ruff, press 'i' to install
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
:Mason          " Should show basedpyright, debugpy, ruff installed
```

---

## LSP Features

Yoda.nvim uses `basedpyright` for Python LSP support — a community-maintained fork of Microsoft's pyright with additional features and performance improvements.

### Code Completion

Automatic as you type. Powered by basedpyright.

Features:
- Function/method completions with signatures
- Module and attribute completions
- Auto-import suggestions
- Keyword completions
- Type-aware completions

### Type Checking

basedpyright provides real-time type checking as you type.

```python
def greet(name: str) -> str:
    return f"Hello, {name}"

greet("Yoda")       # ✅ OK
greet(42)           # ❌ Error: Argument of type "int" not assignable to "str"
```

**Type checking mode**: Set to `"basic"` by default for a balance of strictness and usability. Upgrade to `"strict"` in `pyrightconfig.json` for maximum type safety.

### Auto-Imports

basedpyright automatically suggests and adds imports:

```python
# Type: Path
# basedpyright suggests: from pathlib import Path
```

Press `<CR>` to accept the auto-import.

### Go to Definition

| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover documentation |

### Code Actions

| Keymap | Action |
|--------|--------|
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |

Available code actions:
- Add missing imports
- Remove unused imports
- Extract to function or variable
- Add type annotations
- Implement abstract methods

### Project Root Detection

basedpyright automatically detects Python projects using these root markers (in order of precedence):
- `pyproject.toml`
- `setup.py`
- `setup.cfg`
- `requirements.txt`
- `Pipfile`
- `pyrightconfig.json`
- `.git`

### pyrightconfig.json

Control type checking strictness per project:

```json
{
  "typeCheckingMode": "basic",
  "pythonVersion": "3.12",
  "include": ["src"],
  "exclude": ["**/__pycache__", ".venv"]
}
```

Available modes: `"off"`, `"basic"`, `"standard"`, `"strict"`

---

## Debugging

Yoda.nvim uses `debugpy` for Python debugging via `nvim-dap`.

### Setup Debugging

1. Ensure debugpy is installed (`:Mason` or `pip install debugpy`)
2. Open a Python file
3. Set breakpoints
4. Start debugging

### Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>pd` | Debug nearest test method |
| `<leader>pD` | Debug nearest test class |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / Start debug |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>dO` | Step out |
| `<leader>dq` | Terminate debug session |
| `<leader>du` | Toggle DAP UI |

### Debugging Workflow

1. **Set breakpoint**: Place cursor on line, press `<leader>db`
2. **Start debugger**: Press `<leader>dc` (select a configuration)
3. **Select configuration**:
   - Launch file (debug current file)
   - Launch file with arguments (prompts for CLI args)
   - Attach (attach to running process)
   - Debug pytest tests
4. **Control execution**:
   - `<leader>dc` — Continue
   - `<leader>do` — Step over
   - `<leader>di` — Step into
5. **Inspect variables**: Check DAP UI panels
6. **Stop**: `<leader>dq`

### Debug Configurations

#### Launch Current File

Runs the current Python file with the debugger attached. Uses the active virtual environment automatically.

#### Launch File with Arguments

Prompts for command-line arguments before starting. Useful for scripts that accept `sys.argv`.

```python
# Example: debug a script that takes arguments
import sys

def main(args):
    print(f"Processing: {args}")

if __name__ == "__main__":
    main(sys.argv[1:])
```

Press `<leader>dc`, select "Launch file with arguments", enter your args.

#### Debug pytest Tests

**Debug a test method**:
1. Place cursor inside the test function
2. Press `<leader>pd`

**Debug a test class**:
1. Place cursor inside the test class
2. Press `<leader>pD`

Runs with `justMyCode = false` so you can step into library code.

---

## Testing

Yoda.nvim uses **pytest** via neotest for Python testing.

### Test Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>pt` | Run nearest test |
| `<leader>pT` | Run all tests in file |
| `<leader>pC` | Run test suite |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Toggle test output |
| `<leader>pd` | Debug nearest test method |
| `<leader>pD` | Debug nearest test class |

### Test Workflow

#### Running Tests

1. **Write a test**:
```python
def test_addition():
    assert 2 + 2 == 4

def test_string_format():
    name = "Yoda"
    assert f"Hello, {name}" == "Hello, Yoda"
```

2. **Run test**: Place cursor in test function, press `<leader>pt`

3. **View results**:
   - Inline icons show pass/fail status
   - `<leader>ts` — Open test summary panel
   - `<leader>to` — See detailed output

#### Test Classes

```python
class TestMath:
    def test_addition(self):
        assert 1 + 1 == 2

    def test_subtraction(self):
        assert 5 - 3 == 2
```

Run entire class: Place cursor in class, press `<leader>pC`.

#### Fixtures and Parametrize

```python
import pytest

@pytest.fixture
def sample_data():
    return {"name": "Yoda", "age": 900}

def test_with_fixture(sample_data):
    assert sample_data["name"] == "Yoda"

@pytest.mark.parametrize("a,b,expected", [
    (1, 2, 3),
    (0, 0, 0),
    (-1, 1, 0),
])
def test_add(a, b, expected):
    assert a + b == expected
```

### Debug Tests

To debug a failing test:
1. Set breakpoint in test
2. Press `<leader>pd` to debug the test method
3. Use standard DAP keymaps to step through

### pytest Configuration

Create `pytest.ini` or `pyproject.toml`:

```toml
# pyproject.toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "-v"
```

---

## Virtual Environments

Yoda.nvim has automatic virtual environment detection and LSP integration.

### Auto-Detection

When you open a Python file, Yoda automatically searches for virtual environments in this order:

1. `<project_root>/.venv/bin/python`
2. `<project_root>/venv/bin/python`
3. `<project_root>/env/bin/python`
4. `<cwd>/.venv/bin/python`
5. `<cwd>/venv/bin/python`
6. `<cwd>/env/bin/python`

The detected venv is automatically applied to basedpyright so completions and type checking use your project's packages.

### Manual Selection

```vim
<leader>pv      " Open venv selector
```

or

```vim
:VenvSelect
:YodaPythonVenv
```

Browse and select from all available virtual environments on your system.

### Cache Management

The venv detection is cached (5 minute TTL) for performance.

```vim
:PythonVenvDetect   " Re-detect venv (clears cache)
:PythonVenvCache    " Show cache statistics
:PythonVenvClear    " Clear all cached venv entries
```

### Creating Virtual Environments

```bash
# Using venv (built-in)
python -m venv .venv
source .venv/bin/activate

# Using uv (fast, recommended)
uv venv .venv
source .venv/bin/activate

# Using conda
conda create -n myproject python=3.12
conda activate myproject
```

After creating, open a Python file in Neovim — the venv will be auto-detected.

### Auto-Restart on Project Switch

When you change directories (e.g., switching between projects), basedpyright automatically restarts with the new project's configuration. A 1000ms debounce prevents rapid restarts when navigating.

---

## Linting & Formatting

Yoda.nvim uses **ruff** for both linting and formatting — an ultra-fast Python tool written in Rust.

### Why ruff?

- ⚡ **10-100x faster** than ESLint-equivalent tools (flake8, pylint)
- 🎯 **All-in-one** tool (lint + format, replaces flake8, isort, black)
- 🦀 **Written in Rust**, extremely fast
- 📦 **Zero config** for most projects

### Formatting

**Auto-format on save**: Enabled by default (500ms timeout)

**Manual format**:
```vim
<leader>f       " Format buffer
```

### Linting

ruff runs automatically on:
- Buffer write (`BufWritePost`)
- Leaving insert mode (`InsertLeave`)

**View diagnostics**:
```vim
<leader>pe      " Open diagnostics in Trouble
<leader>fD      " Find diagnostics with Telescope
```

### ruff Configuration

Create `pyproject.toml` or `ruff.toml`:

```toml
# pyproject.toml
[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W"]
ignore = ["E501"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

```toml
# ruff.toml (standalone)
line-length = 100
target-version = "py312"

[lint]
select = ["E", "F", "I"]
```

### Common ruff Rule Sets

| Code | Description |
|------|-------------|
| `E` | pycodestyle errors |
| `F` | pyflakes (unused imports, undefined names) |
| `I` | isort (import ordering) |
| `N` | pep8-naming |
| `W` | pycodestyle warnings |
| `B` | flake8-bugbear |
| `UP` | pyupgrade (modernize syntax) |

---

## Type Checking

### basedpyright Type Checking

basedpyright provides real-time type checking inline. Errors appear as diagnostics in the editor.

```python
from typing import Optional

def process(value: Optional[int]) -> str:
    return str(value)  # ⚠️ Could be None

def process_safe(value: Optional[int]) -> str:
    if value is None:
        return "none"
    return str(value)  # ✅ OK
```

### mypy (Additional Type Checking)

For stricter or additional type checking, run mypy:

```vim
<leader>pm      " Run mypy on current file
```

This executes `mypy <current-file>` and shows output in a terminal.

**Install mypy**:
```bash
pip install mypy
# or
uv pip install mypy
```

**mypy configuration** (`pyproject.toml`):

```toml
[tool.mypy]
python_version = "3.12"
strict = true
ignore_missing_imports = true
```

### Comparison

| Tool | Speed | Strictness | Integration |
|------|-------|------------|-------------|
| basedpyright | ⚡⚡⚡ | Configurable | Real-time inline |
| mypy | ⚡⚡ | Configurable | On-demand (`<leader>pm`) |

Use basedpyright for interactive development and mypy for pre-commit or CI validation.

---

## Python REPL

### Interactive Python Shell

Open an interactive Python REPL:

```vim
<leader>pi      " Open Python REPL in floating terminal
```

### Features

- ✅ **Floating terminal** — Doesn't split your layout
- ✅ **Persistent** — Toggle on/off with same keymap
- ✅ **Venv-aware** — Uses active virtual environment
- ✅ **Full REPL** — All Python functionality

### REPL Workflow

```vim
<leader>pi      " Open REPL

# In REPL:
>>> from pathlib import Path
>>> list(Path('.').glob('*.py'))
[PosixPath('main.py'), PosixPath('utils.py')]

>>> exit()      # Or press <leader>pi to close
```

### REPL with venv

If a virtual environment is detected, the REPL automatically uses it:

```bash
# Notification: "Python REPL using venv: /path/to/project/.venv"
```

You get access to all packages installed in your venv.

---

## Code Navigation

### Outline View (Aerial)

View code structure with `aerial.nvim`.

**Toggle outline**:
```vim
<leader>po      " Toggle outline sidebar
```

Shows:
- Functions and methods
- Classes
- Module-level constants
- Decorators

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

### Code Coverage

View test coverage inline:

```vim
<leader>pc      " Show code coverage
```

Requires a coverage tool (e.g., `pytest-cov`) to have generated coverage data.

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
| `<leader>pd` | Debug test method | nvim-dap-python |
| `<leader>pD` | Debug test class | nvim-dap-python |
| `<leader>db` | Toggle breakpoint | DAP |
| `<leader>dc` | Continue | DAP |
| `<leader>do` | Step over | DAP |
| `<leader>di` | Step into | DAP |
| `<leader>dO` | Step out | DAP |
| `<leader>dq` | Terminate session | DAP |
| `<leader>du` | Toggle DAP UI | nvim-dap-ui |

#### Code Quality

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>pm` | Run mypy | Terminal |
| `<leader>pe` | Open diagnostics | Trouble |
| `<leader>pc` | Show coverage | nvim-coverage |

#### Navigation & Environment

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>po` | Toggle outline | Aerial |
| `<leader>pv` | Select venv | venv-selector.nvim |
| `<leader>pL` | Configure LSP with venv | basedpyright |
| `<leader>fR` | Find symbols | Telescope |

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

### Wrong Python interpreter / missing packages

The most common cause is the venv not being detected.

**Manually select venv**:
```vim
<leader>pv      " Browse and select virtual environment
```

**Force re-detection**:
```vim
:PythonVenvDetect
```

**Check cache**:
```vim
:PythonVenvCache    " Show what's cached and TTL
:PythonVenvClear    " Clear cache and retry
```

**Reconfigure LSP**:
```vim
<leader>pL          " Apply detected venv to basedpyright
```

### pyright conflict

Yoda.nvim explicitly disables pyright. If you see two LSP servers attached:

```vim
:StopPyright        " Stop running pyright clients
:UninstallPyright   " Remove pyright from Mason
```

### Debugger not working

**Check debugpy installation**:
```vim
:Mason          " Verify debugpy installed
```

Or install directly:
```bash
pip install debugpy
```

**Check DAP configuration**:
```vim
:lua print(vim.inspect(require("dap").configurations.python))
```

**Common issues**:
1. **Wrong interpreter**: Ensure venv is selected before debugging
2. **Missing debugpy in venv**: Install debugpy inside your venv, not globally
3. **Port in use**: Restart Neovim if a previous debug session hung

### Tests not detected

**Check test file naming**:
- Files: `test_*.py` or `*_test.py`
- Functions: `test_*`
- Classes: `Test*`

**Check pytest installation**:
```bash
pytest --version
# or
python -m pytest --version
```

**Check neotest**:
```vim
:lua require("neotest").run.run()
```

### ruff not linting

**Check ruff installation**:
```vim
:Mason          " Verify ruff installed
```

Or install via pip:
```bash
pip install ruff
```

**Check nvim-lint**:
```vim
:lua print(vim.inspect(require("lint").linters_by_ft.python))
```

### Performance issues / flickering

See `docs/PYTHON_DEBUGGING.md` for detailed performance diagnostics using the autocmd logging system.

Quick check:
```vim
:YodaAutocmdLogEnable   " Enable logging
" Open/edit Python files
:YodaAutocmdLogView     " Inspect what's happening
:YodaAutocmdLogDisable  " Disable when done
```

---

## Best Practices

### 1. Always Use Virtual Environments

Keep project dependencies isolated:
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Yoda.nvim will auto-detect `.venv` in your project root.

### 2. Use Type Annotations

Type annotations enable better completions and error detection:

```python
# Instead of:
def add(a, b):
    return a + b

# Use:
def add(a: int, b: int) -> int:
    return a + b
```

### 3. Debug with Breakpoints

Instead of `print()` everywhere:
```vim
<leader>db      " Set breakpoint
<leader>dc      " Start debugger
```

Inspect variables interactively in the DAP UI.

### 4. Test-Driven Development

Write tests first, use `<leader>pt` to run them as you code.

### 5. Use ruff for Speed

ruff replaces multiple tools with one fast binary:
- Replaces: flake8, pylint, isort, black
- Much faster: runs in milliseconds, not seconds

### 6. Configure pyproject.toml

Centralize all tool configuration:

```toml
[tool.ruff]
line-length = 100

[tool.ruff.lint]
select = ["E", "F", "I", "N"]

[tool.mypy]
strict = true

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v"

[tool.basedpyright]
typeCheckingMode = "basic"
```

### 7. Use Outline for Large Files

In large modules:
```vim
<leader>po      " Open outline to navigate classes and functions
```

---

## Comparison: Python vs Other Languages

| Feature | Python 🐍 | JavaScript 🟨 | Rust 🦀 |
|---------|-----------|---------------|---------|
| **LSP** | basedpyright | ts_ls | rust-analyzer |
| **Inlay Hints** | ❌ | ✅ TypeScript | ✅ |
| **DAP** | debugpy | vscode-js-debug | codelldb |
| **Testing** | neotest-python | neotest-jest/vitest | neotest-rust |
| **Linting** | ruff | Biome | Clippy |
| **Formatting** | ruff_format | Biome/Prettier | rustfmt |
| **Keymaps** | `<leader>p*` | `<leader>j*` | `<leader>r*` |
| **Setup** | `:YodaPythonSetup` | `:YodaJavaScriptSetup` | `:YodaRustSetup` |
| **Venv/Pkg Mgmt** | venv-selector.nvim | package-info.nvim | crates.nvim |

### Python Unique Features

- 🐍 **Virtual environment management** (auto-detection + venv-selector)
- 🔬 **mypy integration** (`<leader>pm` for strict type checking)
- 📊 **Coverage visualization** (`<leader>pc`)
- 🔄 **Auto LSP restart** on project directory change
- ⚡ **Performance tuned** — semantic tokens disabled, highlight debounced

---

## Resources

### Official Documentation

- [basedpyright Docs](https://docs.basedpyright.com/)
- [debugpy Docs](https://github.com/microsoft/debugpy)
- [ruff Docs](https://docs.astral.sh/ruff/)
- [pytest Docs](https://docs.pytest.org/)

### Plugin Documentation

- [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python)
- [neotest-python](https://github.com/nvim-neotest/neotest-python)
- [venv-selector.nvim](https://github.com/linux-cultist/venv-selector.nvim)

### Yoda.nvim Docs

- [Python Debugging Guide](PYTHON_DEBUGGING.md) — Diagnosing performance/flickering issues
- [LSP Guide](overview/LSP.md)
- [Debugging Guide](overview/DEBUGGING.md)
- [Troubleshooting](TROUBLESHOOTING.md)

---

> *"Always in motion is the future."* — Yoda

Happy Python coding! 🐍
