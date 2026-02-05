-- lua/yoda/buffer/type_cache.lua
-- Buffer type caching for performance optimization

local M = {}

-- ============================================================================
-- Configuration
-- ============================================================================

local CACHE_CONFIG = {
  TTL = 5000, -- 5 seconds TTL (balance between freshness and performance)
  MAX_ENTRIES = 500, -- Prevent unbounded growth
}

-- ============================================================================
-- Cache Storage
-- ============================================================================

-- Weak table for automatic garbage collection of deleted buffers
local buffer_cache = setmetatable({}, { __mode = "k" })

-- Cache statistics for monitoring
local cache_stats = {
  hits = 0,
  misses = 0,
  evictions = 0,
  invalidations = 0,
}

-- ============================================================================
-- Cache Entry Structure
-- ============================================================================

--- Create a cache entry for a buffer
--- @param buf number Buffer number
--- @return table entry Cache entry with buffer properties
local function create_cache_entry(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end

  local bo = vim.bo[buf]
  local bufname = vim.api.nvim_buf_get_name(buf)

  return {
    -- Buffer properties
    buftype = bo.buftype,
    filetype = bo.filetype,
    bufname = bufname,
    buflisted = bo.buflisted,
    modifiable = bo.modifiable,
    readonly = bo.readonly,

    -- Derived properties (computed once)
    is_special = bo.buftype ~= "",
    is_real_file = bo.buftype == "" and bo.filetype ~= "" and bo.filetype ~= "alpha" and bufname ~= "",
    is_empty = bufname == "" or bufname == "[No Name]",
    is_scratch = bufname:match("%[Scratch%]") ~= nil,
    is_snacks = bufname:match("snacks_") ~= nil,
    is_bracketed = bufname:match("^%[.-%]$") ~= nil,

    -- Cache metadata
    timestamp = vim.loop.hrtime(),
    access_count = 0,
  }
end

-- ============================================================================
-- Cache Operations
-- ============================================================================

--- Get cached buffer properties
--- @param buf number Buffer number
--- @return table|nil entry Cached entry or nil
function M.get(buf)
  local entry = buffer_cache[buf]

  if not entry then
    cache_stats.misses = cache_stats.misses + 1
    return nil
  end

  -- Check if entry is expired
  local age = (vim.loop.hrtime() - entry.timestamp) / 1000000 -- Convert to ms
  if age > CACHE_CONFIG.TTL then
    buffer_cache[buf] = nil
    cache_stats.evictions = cache_stats.evictions + 1
    cache_stats.misses = cache_stats.misses + 1
    return nil
  end

  -- Update access count
  entry.access_count = entry.access_count + 1
  cache_stats.hits = cache_stats.hits + 1

  return entry
end

--- Get or create cached buffer properties
--- @param buf number Buffer number
--- @return table|nil entry Cache entry or nil if invalid
function M.get_or_create(buf)
  local entry = M.get(buf)

  if entry then
    return entry
  end

  -- Create new entry
  entry = create_cache_entry(buf)
  if entry then
    buffer_cache[buf] = entry

    -- Enforce max entries limit
    M.enforce_size_limit()
  end

  return entry
end

--- Invalidate cache entry for a buffer
--- @param buf number|nil Buffer number (nil for all buffers)
function M.invalidate(buf)
  if buf then
    if buffer_cache[buf] then
      buffer_cache[buf] = nil
      cache_stats.invalidations = cache_stats.invalidations + 1
    end
  else
    buffer_cache = setmetatable({}, { __mode = "k" })
    cache_stats.invalidations = cache_stats.invalidations + 1
  end
end

--- Enforce maximum cache size
function M.enforce_size_limit()
  local count = 0
  for _ in pairs(buffer_cache) do
    count = count + 1
  end

  if count <= CACHE_CONFIG.MAX_ENTRIES then
    return
  end

  -- Evict least recently accessed entries
  local entries = {}
  for buf, entry in pairs(buffer_cache) do
    table.insert(entries, { buf = buf, entry = entry })
  end

  -- Sort by access count (ascending)
  table.sort(entries, function(a, b)
    return a.entry.access_count < b.entry.access_count
  end)

  -- Remove oldest 10%
  local to_remove = math.floor(CACHE_CONFIG.MAX_ENTRIES * 0.1)
  for i = 1, to_remove do
    buffer_cache[entries[i].buf] = nil
    cache_stats.evictions = cache_stats.evictions + 1
  end
end

-- ============================================================================
-- Convenience Functions
-- ============================================================================

--- Check if buffer is a special buffer (not a regular file)
--- @param buf number Buffer number
--- @return boolean
function M.is_special_buffer(buf)
  local entry = M.get_or_create(buf)
  return entry and entry.is_special or false
end

--- Check if buffer is a real file buffer
--- @param buf number Buffer number
--- @return boolean
function M.is_real_file_buffer(buf)
  local entry = M.get_or_create(buf)
  return entry and entry.is_real_file or false
end

--- Check if buffer is empty
--- @param buf number Buffer number
--- @return boolean
function M.is_empty_buffer(buf)
  local entry = M.get_or_create(buf)
  return entry and entry.is_empty or false
end

--- Check if buffer is a scratch buffer
--- @param buf number Buffer number
--- @return boolean
function M.is_scratch_buffer(buf)
  local entry = M.get_or_create(buf)
  return entry and entry.is_scratch or false
end

--- Check if buffer is a snacks buffer
--- @param buf number Buffer number
--- @return boolean
function M.is_snacks_buffer(buf)
  local entry = M.get_or_create(buf)
  return entry and entry.is_snacks or false
end

--- Get buffer type (cached)
--- @param buf number Buffer number
--- @return string|nil
function M.get_buftype(buf)
  local entry = M.get_or_create(buf)
  return entry and entry.buftype
end

--- Get filetype (cached)
--- @param buf number Buffer number
--- @return string|nil
function M.get_filetype(buf)
  local entry = M.get_or_create(buf)
  return entry and entry.filetype
end

--- Get buffer name (cached)
--- @param buf number Buffer number
--- @return string|nil
function M.get_bufname(buf)
  local entry = M.get_or_create(buf)
  return entry and entry.bufname
end

-- ============================================================================
-- Statistics & Monitoring
-- ============================================================================

--- Get cache statistics
--- @return table stats Cache statistics
function M.get_stats()
  local cache_size = 0
  local expired_count = 0
  local now = vim.loop.hrtime()

  for _, entry in pairs(buffer_cache) do
    cache_size = cache_size + 1
    local age = (now - entry.timestamp) / 1000000
    if age > CACHE_CONFIG.TTL then
      expired_count = expired_count + 1
    end
  end

  local total = cache_stats.hits + cache_stats.misses
  local hit_rate = total > 0 and (cache_stats.hits / total * 100) or 0

  return {
    size = cache_size,
    max_size = CACHE_CONFIG.MAX_ENTRIES,
    expired = expired_count,
    ttl_ms = CACHE_CONFIG.TTL,
    hits = cache_stats.hits,
    misses = cache_stats.misses,
    hit_rate = hit_rate,
    evictions = cache_stats.evictions,
    invalidations = cache_stats.invalidations,
  }
end

--- Reset cache statistics
function M.reset_stats()
  cache_stats = {
    hits = 0,
    misses = 0,
    evictions = 0,
    invalidations = 0,
  }
end

--- Get detailed cache info for debugging
--- @return table info Detailed cache information
function M.get_debug_info()
  local entries = {}
  local now = vim.loop.hrtime()

  for buf, entry in pairs(buffer_cache) do
    local age = (now - entry.timestamp) / 1000000
    table.insert(entries, {
      buf = buf,
      buftype = entry.buftype,
      filetype = entry.filetype,
      bufname = entry.bufname,
      age_ms = age,
      access_count = entry.access_count,
      is_expired = age > CACHE_CONFIG.TTL,
    })
  end

  -- Sort by access count (descending)
  table.sort(entries, function(a, b)
    return a.access_count > b.access_count
  end)

  return {
    entries = entries,
    stats = M.get_stats(),
  }
end

-- ============================================================================
-- Setup & Autocmds
-- ============================================================================

--- Setup autocmds for cache invalidation
function M.setup_autocmds()
  local augroup = vim.api.nvim_create_augroup("YodaBufferTypeCache", { clear = true })

  -- Invalidate on buffer changes
  vim.api.nvim_create_autocmd({ "BufFilePost", "FileType" }, {
    group = augroup,
    desc = "Invalidate buffer type cache on buffer changes",
    callback = function(args)
      M.invalidate(args.buf)
    end,
  })

  -- Invalidate on buffer delete
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = augroup,
    desc = "Invalidate buffer type cache on buffer deletion",
    callback = function(args)
      M.invalidate(args.buf)
    end,
  })

  -- Periodic cleanup of expired entries
  vim.fn.timer_start(10000, function()
    local now = vim.loop.hrtime()
    for buf, entry in pairs(buffer_cache) do
      local age = (now - entry.timestamp) / 1000000
      if age > CACHE_CONFIG.TTL then
        buffer_cache[buf] = nil
        cache_stats.evictions = cache_stats.evictions + 1
      end
    end
  end, { ["repeat"] = -1 })
end

--- Setup user commands
function M.setup_commands()
  vim.api.nvim_create_user_command("BufferCacheStats", function()
    local stats = M.get_stats()
    local lines = {
      "=== Buffer Type Cache Statistics ===",
      string.format("Cache size: %d / %d (%.1f%%)", stats.size, stats.max_size, stats.size / stats.max_size * 100),
      string.format("Expired entries: %d", stats.expired),
      string.format("TTL: %dms", stats.ttl_ms),
      "",
      "Performance:",
      string.format("  Hits: %d", stats.hits),
      string.format("  Misses: %d", stats.misses),
      string.format("  Hit rate: %.1f%%", stats.hit_rate),
      string.format("  Evictions: %d", stats.evictions),
      string.format("  Invalidations: %d", stats.invalidations),
    }

    print(table.concat(lines, "\n"))
  end, { desc = "Show buffer type cache statistics" })

  vim.api.nvim_create_user_command("BufferCacheClear", function()
    M.invalidate()
    M.reset_stats()
    print("Buffer type cache cleared")
  end, { desc = "Clear buffer type cache" })

  vim.api.nvim_create_user_command("BufferCacheDebug", function()
    local info = M.get_debug_info()
    print("=== Buffer Type Cache Debug Info ===")
    print(vim.inspect(info))
  end, { desc = "Show detailed buffer cache debug info" })
end

return M
