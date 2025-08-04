# Python Development Guide for Yoda.nvim

A comprehensive guide for Python development in your Yoda.nvim distribution using the available Python-related plugins.

## Overview

Yoda.nvim includes several Python-related plugins for development, testing, and debugging:

- **jedi-knights/python.nvim** - Comprehensive Python development plugin
- **neotest** with **neotest-python** - Test runner and management
- **nvim-dap-python** - Python debugging
- **LSP support** - Python language server integration

## Available Plugins

### jedi-knights/python.nvim

For comprehensive Python development including environment management, formatting, testing, and debugging.

#### Keymaps (all with `<leader>p` prefix):

| Keymap | Description | Action |
|--------|-------------|--------|
| `<leader>pv` | Python: Virtual Environment | Show virtual environment picker |
| `<leader>pi` | Python: Install Package | Install Python package |
| `<leader>pu` | Python: Uninstall Package | Uninstall Python package |
| `<leader>pf` | Python: Format | Format current buffer |
| `<leader>pl` | Python: Lint | Lint current buffer |
| `<leader>po` | Python: Organize Imports | Organize imports in current buffer |
| `<leader>pt` | Python: Test | Run tests |
| `<leader>ptp` | Python: Test Picker | Show test picker |
| `<leader>pd` | Python: Debug | Start debugging session |
| `<leader>pr` | Python: REPL | Open Python REPL |
| `<leader>pp` | Python: Package Picker | Show package picker |
| `<leader>p?` | Python: Info | Show Python.nvim information |

#### Commands:

| Command | Description |
|---------|-------------|
| `:PythonSetup` | Setup Python environment for current project |
| `:PythonVenv` | Manage virtual environments |
| `:PythonInstall` | Install Python package |
| `:PythonUninstall` | Uninstall Python package |
| `:PythonFormat` | Format current buffer |
| `:PythonLint` | Lint current buffer |
| `:PythonTest` | Run tests |
| `:PythonDebug` | Start debugging session |
| `:PythonREPL` | Open Python REPL |
| `:PythonOrganizeImports` | Organize imports in current buffer |
| `:PythonVenvPicker` | Show virtual environment picker |
| `:PythonPackagePicker` | Show package picker |
| `:PythonTestPicker` | Show test picker |
| `:PythonImportPicker` | Show import picker |
| `:PythonToggleDebug` | Toggle debug mode |
| `:PythonInfo` | Show Python.nvim information |

### neotest

For comprehensive test management and execution.

#### Keymaps (all with `<leader>t` prefix):

| Keymap | Description | Action |
|--------|-------------|--------|
| `<leader>ta` | Test: Run All | Run all tests in project |
| `<leader>tn` | Test: Run Nearest | Run nearest test |
| `<leader>tf` | Test: Run File | Run tests in current file |
| `<leader>tl` | Test: Run Last | Run last test |
| `<leader>ts` | Test: Summary | Toggle test summary |
| `<leader>to` | Test: Output | Toggle output panel |
| `<leader>td` | Test: Debug | Debug nearest test with DAP |
| `<leader>tv` | Test: View Output | View test output in floating window |

### nvim-dap-python

For Python debugging capabilities.

#### Keymaps:

| Keymap | Description | Action |
|--------|-------------|--------|
| `<space>?` | Debug: Eval | Evaluate variable under cursor |
| `<F1>` | Debug: Continue | Continue execution |
| `<F2>` | Debug: Step Into | Step into function |
| `<F3>` | Debug: Step Over | Step over function |
| `<F4>` | Debug: Step Out | Step out of function |
| `<F5>` | Debug: Step Back | Step back |
| `<F6>` | Debug: Restart | Restart debugging session |

## Development Workflow

### 1. Environment Management with python.nvim

1. **Setup environment** with `:PythonSetup` or `<leader>pv`
2. **Install packages** with `<leader>pi` or `:PythonInstall`
3. **Manage virtual environments** with `<leader>pv`
4. **Check information** with `<leader>p?`

### 2. Code Quality with python.nvim

1. **Format code** using `<leader>pf` or `:PythonFormat`
2. **Lint code** using `<leader>pl` or `:PythonLint`
3. **Organize imports** using `<leader>po` or `:PythonOrganizeImports`
4. **Auto-format on save** is enabled by default

### 3. Testing with python.nvim

1. **Run tests** using `<leader>pt` or `:PythonTest`
2. **Use test picker** with `<leader>ptp` or `:PythonTestPicker`
3. **View test results** in the output window

### 4. Testing with neotest

1. **Position cursor** near a test function
2. **Run nearest test** using `<leader>tn`
3. **View test summary** with `<leader>ts`
4. **Debug tests** with `<leader>td`

### 5. Debugging with python.nvim

1. **Start debugging** with `<leader>pd` or `:PythonDebug`
2. **Use REPL** with `<leader>pr` or `:PythonREPL`
3. **Toggle debug mode** with `:PythonToggleDebug`

### 6. Debugging with nvim-dap-python

1. **Set breakpoints** in your Python code
2. **Start debugging** with `<F1>`
3. **Step through code** with F2-F4
4. **Evaluate variables** with `<space>?`

### 7. LSP Integration

1. **Install Python LSP** via Mason
2. **Get code intelligence** and autocompletion
3. **Use LSP keymaps** for navigation and refactoring

## Configuration

### python.nvim Configuration

```lua
require("python").setup({
  -- Enable all Python features
  enable_virtual_env = true,
  auto_detect_venv = true,
  enable_type_checking = true,
  enable_auto_import = true,
  
  -- Testing configuration
  test_frameworks = {
    pytest = { enabled = true },
    unittest = { enabled = true },
    nose = { enabled = false },
  },
  
  -- Task runner configuration
  task_runner = {
    enabled = true,
    invoke = { enabled = true },
    make = { enabled = true },
    scripts = { enabled = true },
  },
  
  -- Formatting and linting
  formatters = {
    black = { enabled = true, line_length = 88 },
    isort = { enabled = true, profile = "black" },
    autopep8 = { enabled = false },
  },
  
  linters = {
    flake8 = { enabled = true },
    pylint = { enabled = false },
    mypy = { enabled = true },
  },
  
  -- Debugging and REPL
  debugger = {
    enabled = true,
    adapter = "debugpy",
    port = 5678,
  },
  
  repl = {
    enabled = true,
    floating = true,
    auto_import = true,
  },
  
  -- Coverage
  test_coverage = {
    enabled = true,
    tool = "coverage",
    show_inline = true,
  },
})
```

### neotest Configuration

```lua
require("neotest").setup({
  adapters = {
    require("neotest-python")({
      dap = { justMyCode = false },
      runner = "pytest",
      python = vim.fn.exepath("python3"),
    }),
  },
})
```

### nvim-dap-python Configuration

```lua
require("dap-python").setup("python3")
```

## Best Practices

### 1. Environment Management

- Use virtual environments for project isolation
- Use `<leader>pv` to manage virtual environments
- Use `<leader>pi` to install packages
- Check environment with `<leader>p?`

### 2. Code Quality

- Use `<leader>pf` to format code regularly
- Use `<leader>pl` to lint code
- Use `<leader>po` to organize imports
- Enable auto-format on save

### 3. Testing

- Use `<leader>pt` for quick test execution with python.nvim
- Use `<leader>tn` for quick test iteration with neotest
- Use `<leader>ts` to see test summary
- Use `<leader>td` to debug failing tests

### 4. Workflow Tips

- **Use `<leader>p?`** to check Python environment status
- **Use `<leader>pv`** to switch virtual environments
- **Use `<leader>pr`** for interactive development
- **Use `<leader>pd`** for debugging
- **Use `<space>?`** to evaluate variables during debugging

### 5. Integration with Yoda.nvim

- **Automatic loading** when opening Python files
- **Keymaps integrated** with your existing workflow
- **Terminal integration** for REPL and output
- **LSP integration** for code intelligence

## Troubleshooting

### Common Issues

1. **Python not found**
   - Check Python installation: `python3 --version`
   - Use `<leader>p?` to check environment status
   - Verify PATH environment variable

2. **Keymaps not working**
   - Ensure plugins are loaded
   - Check for conflicts with other plugins
   - Restart Neovim if needed

3. **Virtual environment issues**
   - Use `<leader>pv` to manage environments
   - Check environment with `<leader>p?`
   - Verify Python path and packages

4. **Debugging not working**
   - Install debugpy: `pip install debugpy`
   - Check Python path and virtual environment
   - Verify DAP configuration

### Debug Commands

```vim
" Check if python.nvim is loaded
:lua print(require('python'))

" Check if neotest is loaded
:lua print(require('neotest'))

" Check current Python environment
:PythonInfo

" Check virtual environment status
:PythonVenv
```

## Summary

Yoda.nvim provides comprehensive Python development capabilities:

- **Environment management** with python.nvim
- **Code quality** with formatting and linting
- **Testing** with python.nvim and neotest
- **Debugging** with python.nvim and nvim-dap-python
- **LSP support** for code intelligence
- **Integration** with your existing workflow

Use the appropriate tool for your needs:
- **python.nvim** for comprehensive Python development
- **neotest** for advanced test management
- **nvim-dap-python** for debugging
- **LSP** for code intelligence and refactoring 