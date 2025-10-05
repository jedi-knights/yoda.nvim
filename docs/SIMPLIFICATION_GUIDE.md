# Yoda.nvim Simplification Guide

This document explains the simplification changes made to Yoda.nvim to make it easier to maintain and understand, inspired by [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

## What Changed

### Phase 1: Keymap Consolidation ✅ COMPLETED

**Before:**
```
lua/yoda/core/
  ├── keymaps.lua              (54 lines)
  └── keymaps_consolidated.lua (386 lines)
```

**After:**
```
lua/yoda/config/
  └── keymaps.lua              (~450 lines, all keymaps)
```

**Benefits:**
- ✅ Single file for all keymaps
- ✅ Clear section organization
- ✅ No abstraction layers
- ✅ Easy to find and modify keymaps
- ✅ Kickstart-style simplicity

### Changes to `lua/yoda/init.lua`

**Removed:**
- Global keymap logging (`_G.yoda_keymap_log`)
- Loading of 15+ utility modules
- Complex error handling
- Development tool indicators
- Keymap debugging commands

**Simplified:**
- Cleaner load order
- Essential utilities only
- Core user commands preserved

## How to Use the New Structure

### Finding Keymaps

All keymaps are now in: `lua/yoda/config/keymaps.lua`

Just search for the feature you want:
- Explorer? Search for "EXPLORER"
- LSP? Search for "LSP"
- Git? Search for "GIT"

### Adding New Keymaps

Just add to the appropriate section:

```lua
-- ============================================================================
-- SECTION NAME
-- ============================================================================

map("n", "<leader>x", function()
  -- Your logic here
end, { desc = "Description" })
```

### Modifying Existing Keymaps

1. Open `lua/yoda/config/keymaps.lua`
2. Find the section (use search)
3. Modify the keymap
4. Reload with `<leader><leader>r`

## Migration Path (Remaining Phases)

### Phase 2: Plugin Consolidation (TODO)

Consolidate plugin spec files into fewer, more cohesive files:

```
lua/yoda/plugins/
  ├── init.lua          # All plugins or splits into:
  ├── editor.lua        # Editor enhancements
  ├── lsp.lua           # LSP configuration
  ├── ai.lua            # AI tools
  └── ui.lua            # UI plugins
```

### Phase 3: Utility Cleanup (TODO)

Remove or consolidate utility files:

**To Remove:**
- `utils/automated_testing.lua` → Move to testing plugin spec
- `utils/config_validator.lua` → Remove (over-engineered)
- `utils/distribution_testing.lua` → Remove (over-engineered)
- `utils/enhanced_plugin_loader.lua` → Remove (Lazy does this)
- `utils/error_handler.lua` → Remove (rarely needed)
- `utils/error_recovery.lua` → Remove (over-complex)
- `utils/feature_discovery.lua` → Remove or move to docs
- `utils/icon_diagnostics.lua` → Remove (debugging tool)
- `utils/interactive_help.lua` → Remove (use :help)
- `utils/keymap_logger.lua` → Remove (debugging tool)
- `utils/keymap_utils.lua` → Remove (merged into keymaps)
- `utils/optimization_helper.lua` → Remove (premature optimization)
- `utils/performance_monitor.lua` → Remove (use :Lazy profile)
- `utils/plugin_helpers.lua` → Merge into plugin specs
- `utils/plugin_loader.lua` → Remove (Lazy does this)
- `utils/plugin_validator.lua` → Remove (over-engineered)
- `utils/startup_profiler.lua` → Remove (use :Lazy profile)
- `utils/tool_indicators.lua` → Remove (rarely useful)
- `utils/treesitter_cleanup.lua` → Remove (one-time task)

**To Keep:**
- `utils/plugin_dev.lua` ✅ (useful for local development)

### Phase 4: Final Structure (TODO)

```
yoda.nvim/
├── init.lua                  # Bootstrap
├── lua/yoda/
│   ├── config/
│   │   ├── keymaps.lua      # All keymaps ✅
│   │   ├── options.lua      # All vim options
│   │   └── autocmds.lua     # All autocommands
│   ├── plugins/
│   │   └── init.lua         # All plugin specs
│   ├── lsp/
│   │   └── init.lua         # LSP configuration
│   └── lib/
│       └── utils.lua        # Minimal shared utilities
├── README.md
└── docs/                     # Documentation
```

## Benefits of Simplification

1. **Easier to Navigate**
   - Everything in predictable locations
   - Less directory nesting
   - Clear naming

2. **Easier to Maintain**
   - Less indirection
   - Clear execution flow
   - Fewer abstractions

3. **Easier to Debug**
   - Linear code flow
   - No hidden magic
   - Obvious dependencies

4. **Easier to Share**
   - New users can understand it
   - Well-commented code
   - Kickstart-like simplicity

5. **Easier to Customize**
   - Modify keymaps directly
   - No need to understand helper functions
   - Clear cause and effect

## Backwards Compatibility

The old keymap files still exist for now. Once you verify everything works:

```bash
# Remove old files
rm lua/yoda/core/keymaps.lua
rm lua/yoda/core/keymaps_consolidated.lua
```

## Testing the New Structure

1. Restart Neovim
2. Test a few keymaps from each section
3. Check for any errors
4. If everything works, remove old files

## Questions?

See the comparison with kickstart.nvim in the main README for more details on the philosophy behind these changes.

