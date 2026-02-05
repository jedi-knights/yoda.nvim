-- tests/unit/buffer/type_cache_spec.lua
-- Tests for buffer type caching

local helpers = require("tests.helpers")

describe("buffer.type_cache", function()
  local type_cache

  before_each(function()
    package.loaded["yoda.buffer.type_cache"] = nil
    type_cache = require("yoda.buffer.type_cache")
    type_cache.invalidate()
    type_cache.reset_stats()
  end)

  after_each(function()
    type_cache.invalidate()
    type_cache.reset_stats()
  end)

  describe("cache operations", function()
    it("caches buffer properties", function()
      local buf = vim.api.nvim_create_buf(false, false)
      vim.api.nvim_buf_set_name(buf, "test.lua")
      vim.bo[buf].filetype = "lua"

      local entry1 = type_cache.get_or_create(buf)
      local entry2 = type_cache.get_or_create(buf)

      assert.is_not_nil(entry1)
      assert.equals(entry1, entry2)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("returns nil for invalid buffer", function()
      local entry = type_cache.get_or_create(99999)
      assert.is_nil(entry)
    end)

    it("tracks cache hits and misses", function()
      local buf = vim.api.nvim_create_buf(false, false)

      type_cache.get_or_create(buf)
      type_cache.get_or_create(buf)

      local stats = type_cache.get_stats()
      assert.equals(1, stats.hits)
      assert.equals(1, stats.misses)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("invalidates specific buffer", function()
      local buf = vim.api.nvim_create_buf(false, false)

      type_cache.get_or_create(buf)
      type_cache.invalidate(buf)

      local stats = type_cache.get_stats()
      assert.equals(0, stats.size)
      assert.equals(1, stats.invalidations)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("invalidates all buffers when no arg provided", function()
      local buf1 = vim.api.nvim_create_buf(false, false)
      local buf2 = vim.api.nvim_create_buf(false, false)

      type_cache.get_or_create(buf1)
      type_cache.get_or_create(buf2)
      type_cache.invalidate()

      local stats = type_cache.get_stats()
      assert.equals(0, stats.size)

      vim.api.nvim_buf_delete(buf1, { force = true })
      vim.api.nvim_buf_delete(buf2, { force = true })
    end)
  end)

  describe("convenience functions", function()
    it("detects special buffers", function()
      local buf = vim.api.nvim_create_buf(false, false)
      vim.bo[buf].buftype = "nofile"

      assert.is_true(type_cache.is_special_buffer(buf))

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("detects real file buffers", function()
      local buf = vim.api.nvim_create_buf(false, false)
      vim.api.nvim_buf_set_name(buf, "test.lua")
      vim.bo[buf].filetype = "lua"

      assert.is_true(type_cache.is_real_file_buffer(buf))

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("detects empty buffers", function()
      local buf = vim.api.nvim_create_buf(false, false)
      assert.is_true(type_cache.is_empty_buffer(buf))

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("detects scratch buffers", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, "[Scratch]")

      assert.is_true(type_cache.is_scratch_buffer(buf))

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("detects snacks buffers", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, "snacks_explorer")

      assert.is_true(type_cache.is_snacks_buffer(buf))

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("property getters", function()
    it("gets cached buftype", function()
      local buf = vim.api.nvim_create_buf(false, false)
      vim.bo[buf].buftype = "nofile"

      local buftype = type_cache.get_buftype(buf)
      assert.equals("nofile", buftype)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("gets cached filetype", function()
      local buf = vim.api.nvim_create_buf(false, false)
      vim.bo[buf].filetype = "lua"

      local filetype = type_cache.get_filetype(buf)
      assert.equals("lua", filetype)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("gets cached bufname", function()
      local buf = vim.api.nvim_create_buf(false, false)
      vim.api.nvim_buf_set_name(buf, "test.lua")

      local bufname = type_cache.get_bufname(buf)
      assert.is_true(bufname:match("test.lua") ~= nil)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("statistics", function()
    it("tracks cache size", function()
      local buf1 = vim.api.nvim_create_buf(false, false)
      local buf2 = vim.api.nvim_create_buf(false, false)

      type_cache.get_or_create(buf1)
      type_cache.get_or_create(buf2)

      local stats = type_cache.get_stats()
      assert.equals(2, stats.size)

      vim.api.nvim_buf_delete(buf1, { force = true })
      vim.api.nvim_buf_delete(buf2, { force = true })
    end)

    it("calculates hit rate", function()
      local buf = vim.api.nvim_create_buf(false, false)

      type_cache.get_or_create(buf)
      type_cache.get_or_create(buf)
      type_cache.get_or_create(buf)

      local stats = type_cache.get_stats()
      assert.equals(2, stats.hits)
      assert.equals(1, stats.misses)
      assert.is_true(stats.hit_rate > 60)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("resets statistics", function()
      local buf = vim.api.nvim_create_buf(false, false)

      type_cache.get_or_create(buf)
      type_cache.reset_stats()

      local stats = type_cache.get_stats()
      assert.equals(0, stats.hits)
      assert.equals(0, stats.misses)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("cache expiration", function()
    it("expires old entries", function()
      local buf = vim.api.nvim_create_buf(false, false)

      local entry = type_cache.get_or_create(buf)
      assert.is_not_nil(entry)

      entry.timestamp = vim.loop.hrtime() - 10000000000

      local expired = type_cache.get(buf)
      assert.is_nil(expired)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("tracks expired entries in stats", function()
      local buf = vim.api.nvim_create_buf(false, false)

      local entry = type_cache.get_or_create(buf)
      entry.timestamp = vim.loop.hrtime() - 10000000000

      local stats = type_cache.get_stats()
      assert.equals(1, stats.expired)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("cache size limits", function()
    it("enforces maximum cache size", function()
      for i = 1, 510 do
        local buf = vim.api.nvim_create_buf(false, false)
        type_cache.get_or_create(buf)
      end

      local stats = type_cache.get_stats()
      assert.is_true(stats.size <= 500)
    end)
  end)

  describe("debug info", function()
    it("returns detailed debug information", function()
      local buf = vim.api.nvim_create_buf(false, false)
      vim.bo[buf].filetype = "lua"

      type_cache.get_or_create(buf)

      local info = type_cache.get_debug_info()
      assert.is_not_nil(info.entries)
      assert.is_not_nil(info.stats)
      assert.equals(1, #info.entries)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("sorts entries by access count", function()
      local buf1 = vim.api.nvim_create_buf(false, false)
      local buf2 = vim.api.nvim_create_buf(false, false)

      type_cache.get_or_create(buf1)
      type_cache.get_or_create(buf1)
      type_cache.get_or_create(buf2)

      local info = type_cache.get_debug_info()
      assert.is_true(info.entries[1].access_count >= info.entries[2].access_count)

      vim.api.nvim_buf_delete(buf1, { force = true })
      vim.api.nvim_buf_delete(buf2, { force = true })
    end)
  end)

  describe("commands", function()
    before_each(function()
      type_cache.setup_commands()
    end)

    it("creates BufferCacheStats command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.BufferCacheStats)
    end)

    it("creates BufferCacheClear command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.BufferCacheClear)
    end)

    it("creates BufferCacheDebug command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.BufferCacheDebug)
    end)
  end)

  describe("performance", function()
    it("handles rapid cache requests efficiently", function()
      local buf = vim.api.nvim_create_buf(false, false)
      vim.bo[buf].filetype = "lua"

      local start = vim.loop.hrtime()

      for _ = 1, 100 do
        type_cache.get_or_create(buf)
      end

      local elapsed = (vim.loop.hrtime() - start) / 1000000

      assert.is_true(elapsed < 10)

      local stats = type_cache.get_stats()
      assert.equals(99, stats.hits)
      assert.equals(1, stats.misses)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("handles multiple concurrent buffers", function()
      local buffers = {}

      for i = 1, 50 do
        local buf = vim.api.nvim_create_buf(false, false)
        vim.bo[buf].filetype = "lua"
        table.insert(buffers, buf)
        type_cache.get_or_create(buf)
      end

      local stats = type_cache.get_stats()
      assert.equals(50, stats.size)

      for _, buf in ipairs(buffers) do
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)
  end)
end)
