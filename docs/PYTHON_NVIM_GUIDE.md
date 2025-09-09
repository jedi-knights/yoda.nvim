# Python Development Guide for Yoda.nvim

A comprehensive guide for Python development in your Yoda.nvim distribution using the available Python-related plugins.

## Overview

Yoda.nvim includes several Python-related plugins for development, testing, and debugging:

- **neotest** with **neotest-python** - Test runner and management
- **nvim-dap-python** - Python debugging
- **LSP support** - Python language server integration

**Note:** The `jedi-knights/python.nvim` plugin is currently disabled due to being incomplete and causing errors. It will be re-enabled when the plugin is fully implemented.

## Available Plugins

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

### 1. Testing with neotest

1. **Position cursor** near a test function
2. **Run nearest test** using `<leader>tn`
3. **View test summary** with `<leader>ts`
4. **Debug tests** with `<leader>td`

### 2. Debugging with nvim-dap-python

1. **Set breakpoints** in your Python code
2. **Start debugging** with `<F1>`
3. **Step through code** with F2-F4
4. **Evaluate variables** with `<space>?`

### 3. LSP Integration

1. **Install Python LSP** via Mason
2. **Get code intelligence** and autocompletion
3. **Use LSP keymaps** for navigation and refactoring

## Configuration

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

### 1. Test Organization

- Keep test files named `test_*.py` or `*_test.py`
- Use descriptive test function names
- Group related tests in classes
- Use pytest fixtures for setup/teardown

### 2. Workflow Tips

- **Use `<leader>tn`** for quick test iteration
- **Use `<leader>ts`** to see test summary
- **Use `<leader>td`** to debug failing tests
- **Use `<space>?`** to evaluate variables during debugging

### 3. Integration with Yoda.nvim

- **Automatic loading** when opening test files
- **Keymaps integrated** with your existing workflow
- **Terminal integration** for test output
- **LSP integration** for code intelligence

## Troubleshooting

### Common Issues

1. **Tests not running**
   - Check pytest is installed: `pip install pytest`
   - Verify test file naming convention
   - Check Python path and virtual environment

2. **Keymaps not working**
   - Ensure plugins are loaded
   - Check for conflicts with other plugins
   - Restart Neovim if needed

3. **Debugging not working**
   - Install debugpy: `pip install debugpy`
   - Check Python path and virtual environment
   - Verify DAP configuration

### Debug Commands

```vim
" Check if neotest is loaded
:lua print(require('neotest'))

" Check if nvim-dap-python is loaded
:lua print(require('dap-python'))

" Run plugin tests
:RunPluginTests
```

## Summary

Yoda.nvim provides comprehensive Python development capabilities:

- **Testing** with neotest
- **Debugging** with nvim-dap-python
- **LSP support** for code intelligence
- **Integration** with your existing workflow

Use the appropriate tool for your needs:
- **neotest** for comprehensive test management
- **nvim-dap-python** for debugging
- **LSP** for code intelligence and refactoring

**Future:** When the `jedi-knights/python.nvim` plugin is fully implemented, it will provide additional features like environment management, formatting, and REPL integration. 