#### 🔴 P0: Critical (Do Immediately)

1. ✅ Fix alpha cache race condition (COMPLETED)
 • ✅ Add atomic "creation in progress" flag
 • ✅ Invalidate cache on buffer creation, not just deletion
2. ✅ Fix BufEnter infinite loop potential (COMPLETED)
 • ✅ Add recursion counter with max depth 3
 • ✅ Add timeout to refresh_in_progress tracking (5 seconds)
3. ✅ Fix timer memory leak (COMPLETED)
 • ✅ Wrap all timer callbacks in pcall
 • ✅ Add timer cleanup on VimLeavePre


#### 🟡 P1: High Priority (This Week)

4. ✅ Consolidate FocusGained handlers (COMPLETED)
 • ✅ Single handler that coordinates all refresh logic
5. ✅ Add global BufEnter debounce (COMPLETED)
 • ✅ Skip processing if < 50ms since last BufEnter
6. ✅ Implement GitSigns refresh batching (COMPLETED)
 • ✅ Single 200ms window for all refresh requests


#### 🟢 P2: Medium Priority (This Month)

7. ✅ Refactor alpha_manager complexity (COMPLETED)
 • ✅ Reduce cyclomatic complexity to ≤7
8. Add autocmd priority ordering
 • Document execution order expectations
9. Add buffer cache invalidation
 • Periodic cleanup of stale state
10. Add comprehensive autocmd logging
 • Use autocmd_logger for all handlers
 • Add "AUTOCMD_TRACE" mode for debugging
