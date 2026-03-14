# Breaking Changes

This document tracks breaking changes and the migration steps required to adopt them.

Changes are listed newest-first. Each entry records what changed, why it changed,
and how to update any code that depends on the old behavior.

---

## 2026-03 — Code Quality Audit Fixes

These changes were made as part of a comprehensive code quality audit.
No public user-facing API was deliberately broken; all changes either
fix bugs, remove dead code, or tighten internal contracts.

### 1. `lua/plugins/loader.lua` — removed (dead code)

**What changed**: `lua/plugins/loader.lua` was deleted.

**Why**: The file attempted to `require("plugins_new.*")` modules that no longer
exist.  It was unreachable at runtime — `lazy-plugins.lua` already handles plugin
loading via `{ import = "plugins.*" }`.  Keeping it risked confusing future
readers and created a spurious require error if the file were ever loaded.

**Migration**: No action required.  If you had code that explicitly
`require("yoda.plugins.loader")`, remove the call — plugin loading happens
automatically through `lazy-plugins.lua`.

---

### 2. `lua/yoda/python_venv.lua` — executable detection is now async

**What changed**: The internal helper that walks a list of candidate Python
executable paths now uses `vim.uv.fs_stat(path, callback)` (non-blocking) instead
of the synchronous `vim.loop.fs_stat(path)` form.

**Why**: Calling synchronous I/O inside `vim.schedule()` blocks the event loop.
The async form keeps Neovim responsive during venv detection.

**Migration**: The public API (`python_venv.detect_venv()`) is unchanged.
Internal callers that previously received a synchronous return value from the
private `find_first_executable()` helper must now pass a callback.
This helper was never part of the public module table, so no external migration
is needed.

If you have custom test helpers that mock `vim.loop.fs_stat`, update them to
handle both the sync form (no callback — return stat or nil) and the async form
(callback provided — invoke it via `vim.schedule`).  See `tests/helpers.lua` for
the reference implementation.

---

### 3. `lua/yoda/lsp.lua` — error notifications use `vim.notify` directly

**What changed**: The `safe_setup()` function (private, called during `M.setup()`)
now reports LSP configuration errors via `vim.notify` instead of the
`yoda-adapters.notification` adapter.

**Why**: `M.setup()` is called early in the startup sequence, before the
notification adapter is guaranteed to be fully initialised.  Using the adapter
here created a potential nil-method error on startup.  The change is intentionally
narrow — normal operation paths are unaffected.

**Migration**: No action required.  Error messages during LSP server configuration
will now appear as standard `vim.notify` warnings rather than styled adapter
notifications.  This only affects the failure path.

---

### 4. `lua/yoda/lsp_performance.lua` — `venv_detection_times` capped at 50 entries

**What changed**: The `metrics.venv_detection_times` table now holds at most 50
entries.  When the cap is reached, the oldest entry (by insertion order) is evicted
before a new one is added (FIFO).

**Why**: The table is keyed by `root_dir` (an absolute path string).  In long
Neovim sessions or with many open projects the table would grow without bound,
causing a slow memory leak.

**Migration**: Code that reads `venv_detection_times` directly (e.g. custom
monitoring scripts) should be aware that entries may be absent even for directories
that were previously tracked.  The public `get_metrics()` / `reset_metrics()`
interface is unchanged.

---

### 5. `lua/yoda/container.lua` — `M.evict(name)` added; `M.reset()` is test-only

**What changed**:

- **New method** `M.evict(name)` — evicts a single cached service instance from
  the container without removing its factory or affecting other services.  The next
  call to `M.resolve(name)` will re-run the factory.

- **`M.reset()` documented as test-only** — the docstring now explicitly states
  that `reset()` is intended for use in tests.  At runtime, prefer `evict()` for
  targeted cache invalidation.

**Why**: Previously there was no way to invalidate a single service cache entry
at runtime (e.g. when a plugin reloads or a dependency changes) without wiping the
entire container state.  `evict()` fills this gap without breaking the container's
invariants.

**Migration**: No breaking change — `reset()` still works exactly as before.
New code that previously called `reset()` followed by re-registration to refresh a
single service should switch to `evict()` instead.

---

### 6. `lua/autocmds.lua` — `YodaAlphaClose` augroup self-deletes

**What changed**: The `BufEnter` autocmd in the `YodaAlphaClose` augroup now
deletes itself (via `pcall(vim.api.nvim_del_augroup_by_name, "YodaAlphaClose")`)
after successfully closing all alpha buffers.

**Why**: Once the alpha dashboard has been dismissed it can never reappear in the
same session, so the `BufEnter` check was firing on every subsequent buffer enter
for no reason.  Self-deletion eliminates that overhead.

**Migration**: No action required.  The behaviour (close alpha when a real file
buffer is opened) is identical; the autocmd simply stops running after it has done
its job.

---

### 7. `lua/options.lua` — redundant `set_colorcolumn_highlight()` call removed

**What changed**: The immediate, unconditional call to `set_colorcolumn_highlight()`
that previously followed the `ColorScheme` autocmd registration has been removed.

**Why**: lazy.nvim fires the `ColorScheme` event when it applies the initial
colourscheme at startup, so the autocmd callback already runs once at startup.
The extra call was redundant and caused the highlight to be set twice on startup.

**Migration**: No action required.  The `ColorColumn` highlight is still applied
at startup (via the `ColorScheme` event) and on every subsequent theme change.

---

## Versioning Note

Yoda.nvim does not currently publish tagged releases.  The changes above are
identified by date and commit range.  If you maintain a fork or customise internal
APIs, use `git log --oneline` to locate the relevant commits and review the diffs
before rebasing.
