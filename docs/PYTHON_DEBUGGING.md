# Python Performance Debugging Guide

## Overview

If you're experiencing flickering or performance issues when opening Python files, use the autocmd logging system to diagnose the problem.

## Quick Start

### 1. Enable Logging

```vim
:YodaAutocmdLogEnable
```

This will:
- Create a log file at `~/.local/share/nvim/yoda_autocmd.log`
- Start logging all autocmd events with timestamps
- Show a notification with the log file location

### 2. Reproduce the Issue

1. Open a Python file that exhibits flickering
2. Switch between Python files if the issue occurs during switching
3. Perform any actions that trigger the problem

### 3. View the Log

```vim
:YodaAutocmdLogView
```

This opens the log file in a new buffer for review.

### 4. Analyze the Log

Look for patterns that indicate issues:

**Normal behavior (no flickering):**
```
[12:34:56.123] BufEnter_START buf=1 ft=python bt=none file=test.py
[12:34:56.125] BufEnter_REAL_BUFFER buf=1 filetype=python
[12:34:56.127] Alpha_Close_Check buf=1 delay=150
[12:34:56.129] BufEnter_Skip_Refresh buf=1 reason=python_file
[12:34:56.130] BufEnter_END buf=1 ft=python action=python_skip duration_ms=7.23
[12:34:56.135] Python_LSP_Check event=BufEnter/DirChanged
[12:34:57.145] Python_LSP_Debounce_Fire
[12:34:57.147] Python_LSP_Same_Root root=/path/to/project
```

**Problem indicators:**
```
# Multiple BufEnter events in quick succession (< 50ms apart)
[12:34:56.100] BufEnter_START buf=1 ft=python
[12:34:56.110] BufEnter_START buf=1 ft=python  # <- TOO SOON!
[12:34:56.120] BufEnter_START buf=1 ft=python  # <- WAY TOO SOON!

# LSP restarting frequently
[12:34:56.200] Python_LSP_Root_Change old=/path1 new=/path2
[12:34:56.250] Python_LSP_Root_Change old=/path2 new=/path1  # <- Flip-flopping!

# Alpha dashboard repeatedly opening/closing
[12:34:56.300] Alpha_Close_Delete buf=5
[12:34:56.350] Alpha_Close_Delete buf=5  # <- Trying to delete again
```

### 5. Disable Logging When Done

```vim
:YodaAutocmdLogDisable
```

Or toggle it:
```vim
:YodaAutocmdLogToggle
```

### 6. Clear the Log

```vim
:YodaAutocmdLogClear
```

## Available Commands

| Command | Description |
|---------|-------------|
| `:YodaAutocmdLogEnable` | Start logging autocmd events |
| `:YodaAutocmdLogDisable` | Stop logging autocmd events |
| `:YodaAutocmdLogToggle` | Toggle logging on/off |
| `:YodaAutocmdLogView` | Open the log file for viewing |
| `:YodaAutocmdLogClear` | Clear the log file |

## Log File Format

Each log line contains:
```
[HH:MM:SS.mmm] EVENT_NAME key=value key=value ...
```

- **Timestamp**: High-resolution timestamp (milliseconds)
- **Event Name**: Type of autocmd event
- **buf**: Buffer number
- **ft**: Filetype
- **bt**: Buftype
- **file**: Filename (basename only)
- **duration_ms**: Operation duration for _END events

## Common Events to Look For

### BufEnter Events
- `BufEnter_START` - Buffer enter begins
- `BufEnter_SKIP` - Skipped (snacks/special buffer)
- `BufEnter_REAL_BUFFER` - Real file buffer detected
- `BufEnter_Skip_Refresh` - Refresh operations skipped (Python files)
- `BufEnter_END` - Buffer enter completes

### Alpha Dashboard Events
- `Alpha_Close_Check` - Checking if alpha should close
- `Alpha_Close_Skip` - Alpha close skipped (reason provided)
- `Alpha_Close_Delete` - Alpha buffer deleted

### Python LSP Events
- `Python_LSP_Check` - LSP restart check triggered
- `Python_LSP_Cancel_Pending` - Cancelled pending restart (debounce)
- `Python_LSP_Debounce_Fire` - Debounce timer fired
- `Python_LSP_Same_Root` - Same project root (no restart)
- `Python_LSP_Root_Change` - Project root changed
- `Python_LSP_Restart` - LSP restarting
- `Python_LSP_No_Clients` - No LSP clients to restart

### Refresh Events
- `Refresh_Start` - Buffer refresh starting
- `Refresh_Buffer` - OpenCode buffer refresh
- `Refresh_GitSigns` - Git signs refresh
- `Refresh_GitSigns_Fallback` - Git signs refresh (fallback)

## Interpreting Results

### Healthy Python File Opening

A single Python file open should show:
1. One `BufEnter_START`
2. Skip refresh for Python (`BufEnter_Skip_Refresh`)
3. Alpha close check (if alpha was open)
4. Python LSP check
5. LSP debounce fires after 1000ms
6. Same root (no restart) OR restart with reason

**Total duration**: < 10ms for BufEnter, 1000ms for LSP check

### Problematic Patterns

**Pattern 1: Rapid BufEnter Loops**
```
Multiple BufEnter_START events < 50ms apart
```
**Cause**: Something is triggering buffer changes in a loop  
**Solution**: Check for plugins editing buffers or running `:edit` commands

**Pattern 2: LSP Restart Storms**
```
Python_LSP_Restart happening multiple times per second
```
**Cause**: Project root detection is flip-flopping  
**Solution**: LSP debounce should prevent this (may need longer delay)

**Pattern 3: Alpha Dashboard Thrashing**
```
Multiple Alpha_Close_Delete events in quick succession
```
**Cause**: Alpha buffer being recreated and deleted repeatedly  
**Solution**: Check alpha configuration and buffer management

## Performance Targets

For smooth Python file operations:

| Metric | Target | Acceptable | Poor |
|--------|--------|------------|------|
| BufEnter duration | < 5ms | < 10ms | > 20ms |
| BufEnter frequency | 1x per file open | 2-3x | > 5x |
| LSP restart delay | 1000ms | 1000ms | < 500ms |
| LSP restart frequency | Only on root change | Never | Multiple per minute |

## Current Optimizations

### For Python Files

1. **No buffer refresh operations** - Python LSP handles file watching
2. **No checktime calls** - Prevents forced buffer reloads
3. **No git signs refresh** - LSP events trigger signs naturally
4. **150ms alpha close delay** - Longer than other files (50ms)
5. **1000ms LSP restart debounce** - Prevents rapid restarts
6. **Skip `:edit` on LSP restart** - Let LSP auto-attach naturally

### For All Files

1. **Early exit for snacks buffers** - No processing
2. **Debounced BufEnter operations** - 50ms delay
3. **Cached buffer checks** - 100-150ms cache intervals
4. **Smart cache invalidation** - Only on actual buffer deletion

## Reporting Issues

When reporting Python performance issues, include:

1. **Log output** from `:YodaAutocmdLogView`
2. **Python file size** and project structure
3. **LSP server** (basedpyright, pyright, etc.)
4. **Virtual environment** setup (venv, conda, etc.)
5. **Neovim version** (`:version`)
6. **Steps to reproduce** the flickering

## Advanced Debugging

### Enable Neovim Verbose Logging

```vim
:set verbose=9
:set verbosefile=/tmp/nvim_verbose.log
```

### Check LSP Status

```vim
:LspInfo
:LspStatus
```

### Monitor LSP Attach/Detach

```vim
:lua vim.lsp.set_log_level("debug")
```

Then check `~/.local/state/nvim/lsp.log`

### Profile Startup

```bash
nvim --startuptime startup.log your_file.py
```

## Getting Help

If logging doesn't reveal the issue:

1. Create an issue at https://github.com/jedi-knights/yoda.nvim/issues
2. Attach the autocmd log output
3. Include system info (OS, terminal, Neovim version)
4. Describe the flickering behavior in detail

---

**Note**: Autocmd logging has minimal performance impact but logs can grow large. Remember to disable it when not actively debugging.
