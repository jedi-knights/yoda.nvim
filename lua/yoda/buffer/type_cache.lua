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

-- Plain table; buffer numbers are integers and not GC-collectable in LuaJIT
-- so weak keys (__mode = "k") would be a no-op. Size is managed by enforce_size_limit().
local buffer_cache = {}

-- Timer ID for the periodic TTL-cleanup timer; stored so it can be stopped
-- if setup_autocmds() is called more than once (e.g. in tests).
local cleanup_timer_id = nil

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
    timestamp = vim.uv.hrtime(),
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
    return nil
  end

  -- Check if entry is expired
  local age = (vim.uv.hrtime() - entry.timestamp) / 1000000 -- Convert to ms
  if age > CACHE_CONFIG.TTL then
    buffer_cache[buf] = nil
    return nil
  end

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
    buffer_cache[buf] = nil
  else
    buffer_cache = {}
  end
end

--- Count current cache entries
--- @return number count Number of entries in the cache
function M.count()
  local n = 0
  for _ in pairs(buffer_cache) do
    n = n + 1
  end
  return n
end

--- Enforce maximum cache size by evicting the oldest entries
function M.enforce_size_limit()
  if M.count() <= CACHE_CONFIG.MAX_ENTRIES then
    return
  end

  local entries = {}
  for buf, entry in pairs(buffer_cache) do
    table.insert(entries, { buf = buf, entry = entry })
  end

  -- Sort by timestamp ascending (oldest first)
  table.sort(entries, function(a, b)
    return a.entry.timestamp < b.entry.timestamp
  end)

  local to_remove = math.floor(CACHE_CONFIG.MAX_ENTRIES * 0.1)
  for i = 1, to_remove do
    buffer_cache[entries[i].buf] = nil
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
-- Setup & Autocmds
-- ============================================================================

--- Setup autocmds for cache invalidation (called automatically on module load)
function M.setup_autocmds()
  local augroup = vim.api.nvim_create_augroup("YodaBufferTypeCache", { clear = true })

  -- Invalidate only on FileType changes (more targeted)
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    desc = "Invalidate buffer type cache when filetype changes",
    callback = function(args)
      M.invalidate(args.buf)
    end,
  })

  -- Periodic cleanup of expired entries (30s interval).
  -- Stop any previous timer before creating a new one so setup_autocmds()
  -- is safe to call multiple times (e.g. in tests).
  if cleanup_timer_id then
    vim.fn.timer_stop(cleanup_timer_id)
  end
  cleanup_timer_id = vim.fn.timer_start(30000, function()
    local now = vim.uv.hrtime()
    for buf, entry in pairs(buffer_cache) do
      local age = (now - entry.timestamp) / 1000000
      if age > CACHE_CONFIG.TTL then
        buffer_cache[buf] = nil
      end
    end
  end, { ["repeat"] = -1 })
end

-- Auto-setup on module load
M.setup_autocmds()

return M
