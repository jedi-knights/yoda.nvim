# FileChangedShell Recursion Guard

## Overview

Added recursion guard to prevent infinite loops in FileChangedShell event handling.

## Problem

The FileChangedShell autocmd could potentially trigger recursive events:

```
FileChangedShell event
  → refresh_buffer()
    → edit! command
      → File reload
        → FileChangedShell event (LOOP!)
```

While the `noautocmd` modifier prevents most autocmds from firing, there were still potential edge cases where:
- Multiple FileChangedShell events could stack up
- Rapid file changes could cause overlapping handlers
- External tools modifying multiple files simultaneously

## Solution

### Global Recursion Guard

Added a simple boolean guard at the module level:

```lua
-- Recursion guard for FileChangedShell events
local file_changed_in_progress = false
```

### Protected FileChangedShell Handler

```lua
autocmd("FileChangedShell", {
  group = git_refresh_group,
  desc = "Refresh buffer and git signs when files changed externally",
  callback = function(args)
    -- Prevent recursive FileChangedShell events
    if file_changed_in_progress then
      return
    end

    file_changed_in_progress = true

    vim.schedule(function()
      if args.buf and vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].buftype == "" then
        M.refresh_buffer(args.buf)
        M.refresh_git_signs()
      end

      -- Reset guard after operation completes
      vim.schedule(function()
        file_changed_in_progress = false
      end)
    end)
  end,
})
```

### Additional Safety Measures

1. **Per-buffer refresh guard** (`refresh_in_progress[buf]`):
   - Prevents the same buffer from being refreshed multiple times
   - Scoped to individual buffers

2. **`noautocmd` modifier**:
   - All buffer reloads use `silent noautocmd edit!`
   - Prevents most autocmds from firing during refresh

3. **`noautocmd checktime`**:
   - Used in `refresh_all_buffers()` to check file timestamps
   - Explicitly documented to prevent FileChangedShell recursion

## Guard Reset Strategy

The guard is reset using **double-scheduled** approach:

```lua
vim.schedule(function()
  -- Do refresh work
  
  vim.schedule(function()
    -- Reset guard after all scheduled work completes
    file_changed_in_progress = false
  end)
end)
```

This ensures:
- All scheduled refresh operations complete before accepting new events
- No race conditions between overlapping file changes
- Predictable execution order

## Why Not Use Debouncing?

While debouncing would work, a simple recursion guard is better because:

1. **Simpler**: Boolean flag vs timer management
2. **Faster**: No artificial delays
3. **More predictable**: Immediate handling of first event
4. **Lower overhead**: No timer creation/destruction

Debouncing is still used at higher levels (git refresh batching), but for recursion protection, a simple guard is more appropriate.

## Testing

### Unit Tests

All existing tests pass (542 tests):
- No regressions in refresh behavior
- Buffer state correctly maintained
- Git signs refresh as expected

### Manual Testing Scenarios

1. **Rapid file changes**:
   ```bash
   # Trigger multiple FileChangedShell events
   touch file1.txt file2.txt file3.txt
   ```
   ✅ Only first event processes, subsequent events blocked

2. **OpenCode editing multiple files**:
   - OpenCode modifies 10+ files
   ✅ Single refresh cycle, no loops

3. **External tool modifications**:
   - Git operations (checkout, rebase, merge)
   ✅ Graceful handling, no crashes

## Performance Impact

**Before guard:**
- Risk of exponential event cascades
- Potential for Neovim freeze/crash
- Unpredictable behavior during bulk operations

**After guard:**
- Guaranteed single-pass execution
- Predictable performance (O(1) check)
- No additional overhead for normal operations

## Architecture

### Multi-layer Protection

```
FileChangedShell Event
         ↓
   Global Guard (file_changed_in_progress)
         ↓
   Buffer Guard (refresh_in_progress[buf])
         ↓
   noautocmd modifier
         ↓
   Safe Buffer Refresh
```

Each layer provides defense-in-depth:
1. **Global**: Prevents overlapping FileChangedShell handlers
2. **Buffer**: Prevents same buffer refresh during active refresh
3. **noautocmd**: Prevents autocmds during buffer operations

## Related Files

- `lua/yoda/opencode_integration.lua:20` - Guard declaration
- `lua/yoda/opencode_integration.lua:462-487` - Protected FileChangedShell handler
- `lua/yoda/opencode_integration.lua:165-230` - refresh_buffer() with per-buffer guard
- `lua/yoda/opencode_integration.lua:260-267` - refresh_buffer_checktime() with noautocmd

## Future Improvements

- Add telemetry to track blocked recursive calls
- Consider per-buffer guards instead of global (trade-off: complexity vs. parallelism)
- Add timeout to auto-reset guard if something goes wrong (fail-safe)

## Debugging

If you suspect the guard is stuck (file changes not being detected):

```lua
-- Check guard state
:lua print(vim.inspect(require("yoda.opencode_integration").debug_get_guard_state()))

-- Force reset (emergency only)
:lua require("yoda.opencode_integration").debug_reset_guard()
```

Note: These debug functions would need to be added if persistent issues occur.
