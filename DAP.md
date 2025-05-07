# Neovim DAP (Debug Adapter Protocol) Guide

This guide explains how to use the `nvim-dap` plugin in Neovim with your provided configuration. It’s written to be beginner-friendly so you can get started smoothly.

## 🌟 What is nvim-dap?

`nvim-dap` is a Neovim plugin that brings debugging capabilities into the editor. With it, you can:

- Set and manage breakpoints  
- Start, pause, and stop debugging sessions  
- Step over, into, or out of functions  
- Inspect variables and call stacks  
- Display inline debug information directly in the code

Your configuration also includes:

- **nvim-dap-ui** → A visual interface for debugging  
- **nvim-dap-python** → Python-specific debugger integration  
- **nvim-dap-virtual-text** → Inline display of variable values next to the code

## ⚙️ How your setup works

- **Automatic UI opening:** When you start debugging, the DAP UI opens automatically, showing panels for breakpoints, variables, and stack frames.  
- **Virtual text display:** Variable values and debug info appear inline as virtual text next to your code.  
- **Editor gutter signs:** You’ll see the following icons next to line numbers:  
  - `` → Breakpoint  
  - `` → Breakpoint rejected  
  - `` → Current execution point

## ⌨️ Keybindings (with `<leader>`)

Here’s what each keybinding does:

- `<leader>db` → Toggle breakpoint on the current line  
- `<leader>dc` → Start or continue the debug session  
- `<leader>do` → Step over (skip into functions)  
- `<leader>di` → Step into (enter the function on the current line)  
- `<leader>dO` → Step out (finish the current function and return to the caller)  
- `<leader>dq` → Terminate the debug session  
- `<leader>du` → Toggle the DAP UI window

These mappings help you control the debugger efficiently without typing long commands.

## 🐍 Python-specific setup

Your configuration uses `dap_python.setup("python3")`. To make this work, you need to install the Python debug adapter with the command:

```bash
pip install debugpy
```

Ensure that the python3 command points to the environment where debugpy is installed.:

🚀 Typical workflow
	1.	Open your Python file in Neovim.
	2.	Place the cursor on the line where you want a breakpoint and press <leader>db.
	3.	Press <leader>dc to start debugging.
	4.	Use:
	•	<leader>do → Step over
	•	<leader>di → Step into
	•	<leader>dO → Step out
	5.	Watch variables and stack frames in the DAP UI.
	6.	Press <leader>dq to stop the session.
	7.	Use <leader>du to manually toggle the DAP UI if needed.

✅ Setup checklist
	•	Install required plugins:
	•	nvim-dap
	•	nvim-dap-ui
	•	nvim-dap-python
	•	nvim-dap-virtual-text
	•	Install the Python debug adapter:

Practice the keybindings on a small Python script to get familiar with the workflow.

🔗 Helpful resources
	•	nvim-dap GitHub
	•	nvim-dap-ui GitHub
	•	nvim-dap-python GitHub


