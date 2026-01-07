# Testing Guide for BufEnter Simplification

## Quick Verification

### 1. Basic Mode Switching Test

Open Neovim and test mode transitions:

```vim
" Open a file
:e test.lua

" Switch between modes rapidly
i  " Enter insert mode
<Esc>  " Back to normal
i  " Insert again
<Esc>  " Normal again

" Navigate and switch modes
j j k k  " Move around
i  " Insert
<Esc>  " Normal
```

**Expected:** Instant mode transitions, no lag or delay.

### 2. Buffer Switching Test

Test switching between multiple buffers:

```vim
" Open multiple files
:e file1.lua
:e file2.lua
:e file3.lua

" Switch rapidly between buffers
:bp  " Previous buffer
:bn  " Next buffer
:bp
:bn

" Try with keyboard shortcuts
<C-^>  " Switch to alternate buffer (repeat)
```

**Expected:** Smooth buffer switching, no freezing.

### 3. Alpha Dashboard Test

Test the empty buffer dashboard:

```vim
" Close all buffers to return to alpha
:bd
:bd
:bd

" Alpha dashboard should appear
" Open a new file
:e newfile.lua

" Alpha should close immediately when entering real buffer
```

**Expected:** Alpha appears/disappears smoothly without lag.

### 4. Git Signs Refresh Test

Test git integration (if in a git repository):

```vim
" Edit a file in a git repo
:e tracked_file.lua

" Make a change
i
some change
<Esc>

" Save the file
:w

" Git signs should update automatically (debounced)
" Wait ~150ms and signs should appear in gutter
```

**Expected:** Git signs appear without freezing Neovim.

---

## Performance Monitoring

### Enable Autocmd Logging

```vim
" Enable detailed logging
:YodaAutocmdLogEnable

" Use Neovim normally for a few minutes
" Switch modes, change buffers, edit files

" View the log
:YodaAutocmdLogView

" Disable logging when done
:YodaAutocmdLogDisable
```

**Look for:** Reduced execution times for BufEnter events.

### Check Performance Report

```vim
" Reset metrics
:AutocmdPerfReset

" Use Neovim normally for a few minutes

" View performance report
:AutocmdPerfReport
```

**Look for:**
- `BufEnter_RealBuffer` max time < 20ms
- `BufEnter_Alpha` max time < 30ms
- No slow autocmd warnings (>100ms)

---

## Specific Scenarios to Test

### Scenario 1: Rapid File Editing

```vim
" Open file, edit, switch mode rapidly
:e test.lua
i
some code
<Esc>
i
more code
<Esc>
:w
```

**Check:** No lag when entering insert mode.

### Scenario 2: Multiple Windows

```vim
" Split windows
:split file1.lua
:vsplit file2.lua

" Switch between windows
<C-w>w  " Cycle windows
<C-w>h  " Move left
<C-w>l  " Move right

" Edit in each window
i
edit
<Esc>
```

**Check:** Window switching is smooth, no BufEnter lag.

### Scenario 3: Terminal Mode

```vim
" Open terminal
:terminal

" Switch to terminal-normal mode
<C-\><C-n>

" Back to terminal mode
i

" Exit terminal
exit
```

**Check:** Terminal mode transitions are instant.

### Scenario 4: Special Buffers

```vim
" Open help
:help nvim

" Switch to another buffer
<C-^>

" Back to help
<C-^>

" Open explorer (if using snacks or nvim-tree)
<leader>eo
```

**Check:** Special buffers are handled correctly, no errors.

---

## Edge Cases to Verify

### 1. Deleted Buffers

```vim
:e temp.lua
:bd!
```

**Expected:** No errors about invalid buffers.

### 2. Modified Buffers

```vim
:e file.lua
i
unsaved changes
<Esc>
:bd  " Should prompt to save
```

**Expected:** Buffer delete prompts work normally.

### 3. Many Buffers Open

```vim
" Open 20+ buffers
:args *.lua
:argdo e

" Switch between them
:bn
:bn
:bn
```

**Expected:** No performance degradation with many buffers.

---

## Automated Testing

### Run Test Suite

```bash
# Run all tests
make test

# Should see:
# ✅ All tests passed!
# Success: 542
# Failed: 0
```

### Run Linter

```bash
# Check code style
make lint

# Should see:
# (no output = success)
```

---

## Regression Checklist

Verify these features still work:

- [ ] Alpha dashboard shows on empty buffer
- [ ] Alpha closes when opening real file
- [ ] Git signs appear after saving
- [ ] OpenCode integration works (if installed)
- [ ] Buffer delete (:Bd) works correctly
- [ ] Window splits work normally
- [ ] Terminal buffers work
- [ ] Help buffers work
- [ ] Special buffers (snacks, etc.) are excluded
- [ ] Performance is better (use :AutocmdPerfReport)

---

## Common Issues and Solutions

### Issue: "Invalid buffer" errors

**Cause:** Buffer became invalid between stages
**Solution:** Already handled by revalidation in code
**Verify:** No errors in logs

### Issue: Alpha doesn't appear

**Cause:** Real buffer detection might be off
**Check:**
```vim
:YodaAutocmdLogEnable
" ... switch to empty buffer ...
:YodaAutocmdLogView
" Look for BufEnter_Alpha logs
```

### Issue: Git signs don't update

**Cause:** Debouncing might be too aggressive
**Check:**
```vim
" After saving a file, wait 200ms
" Signs should appear
" If not, check :YodaAutocmdLogView
```

### Issue: Mode switching still has lag

**Cause:** Other autocmds might be heavy
**Check:**
```vim
:AutocmdPerfReport
" Look for other slow autocmds (>100ms)
```

---

## Performance Comparison

### Before Changes

Expected metrics (approx):
- BufEnter avg: 30-50ms
- BufEnter max: 80-120ms
- Mode lag: Noticeable

### After Changes

Expected metrics (approx):
- BufEnter_RealBuffer avg: 5-15ms
- BufEnter_Alpha avg: 10-20ms
- Mode lag: Minimal/none

**How to check:**
```vim
:AutocmdPerfReport
```

---

## Reporting Issues

If you find problems:

1. **Enable logging:**
   ```vim
   :YodaAutocmdLogEnable
   ```

2. **Reproduce the issue**

3. **Collect data:**
   ```vim
   :YodaAutocmdLogView
   :AutocmdPerfReport
   ```

4. **Save logs:**
   - Copy the log file: `~/.local/state/nvim/yoda_autocmd.log`
   - Copy performance report output

5. **Describe:**
   - What you were doing
   - Expected behavior
   - Actual behavior
   - Logs/performance data

---

## Success Criteria

✅ Mode transitions feel instant
✅ No freezing or lag when switching buffers
✅ Git signs update smoothly
✅ Alpha dashboard works as before
✅ All automated tests pass
✅ Performance metrics improved
✅ No "invalid buffer" errors in logs

---

## Next Steps

After verifying these changes work well:

1. Monitor for a few days of normal use
2. Review :AutocmdPerfReport periodically
3. Consider applying similar patterns to other autocmds
4. Move on to other stability fixes (see MODE_STABILITY_FIXES.md)
