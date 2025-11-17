-- tests/unit/core/cache_spec.lua
local cache = require("yoda-core.cache")

describe("core.cache", function()
  describe("new()", function()
    it("creates cache with default TTL", function()
      local c = cache.new()
      assert.is_not_nil(c)
      assert.equals(150, c.ttl_ms)
    end)

    it("creates cache with custom TTL", function()
      local c = cache.new({ ttl_ms = 500 })
      assert.equals(500, c.ttl_ms)
    end)
  end)

  describe("set() and get()", function()
    it("stores and retrieves values", function()
      local c = cache.new()
      c:set("key1", "value1")
      assert.equals("value1", c:get("key1"))
    end)

    it("returns nil for non-existent keys", function()
      local c = cache.new()
      assert.is_nil(c:get("nonexistent"))
    end)

    it("handles nil values correctly", function()
      local c = cache.new()
      c:set("key1", nil)
      assert.is_nil(c:get("key1"))
    end)

    it("handles invalid key types", function()
      local c = cache.new()
      c:set(123, "value")
      assert.is_nil(c:get(123))
    end)
  end)

  describe("TTL expiration", function()
    it("expires entries after TTL", function()
      local c = cache.new({ ttl_ms = 10 }) -- 10ms TTL
      c:set("key1", "value1")

      -- Immediately should work
      assert.equals("value1", c:get("key1"))

      -- Wait for expiration
      vim.wait(20, function()
        return false
      end)

      -- Should be expired
      assert.is_nil(c:get("key1"))
    end)
  end)

  describe("invalidate()", function()
    it("removes specific entry", function()
      local c = cache.new()
      c:set("key1", "value1")
      c:set("key2", "value2")

      c:invalidate("key1")

      assert.is_nil(c:get("key1"))
      assert.equals("value2", c:get("key2"))
    end)
  end)

  describe("clear()", function()
    it("removes all entries", function()
      local c = cache.new()
      c:set("key1", "value1")
      c:set("key2", "value2")

      c:clear()

      assert.is_nil(c:get("key1"))
      assert.is_nil(c:get("key2"))
    end)
  end)

  describe("has()", function()
    it("returns true for valid cached entries", function()
      local c = cache.new()
      c:set("key1", "value1")
      assert.is_true(c:has("key1"))
    end)

    it("returns false for missing entries", function()
      local c = cache.new()
      assert.is_false(c:has("nonexistent"))
    end)

    it("returns false for expired entries", function()
      local c = cache.new({ ttl_ms = 10 })
      c:set("key1", "value1")

      vim.wait(20, function()
        return false
      end)

      assert.is_false(c:has("key1"))
    end)
  end)

  describe("get_or_compute()", function()
    it("returns cached value if available", function()
      local c = cache.new()
      c:set("key1", "cached_value")

      local compute_called = false
      local result = c:get_or_compute("key1", function()
        compute_called = true
        return "computed_value"
      end)

      assert.equals("cached_value", result)
      assert.is_false(compute_called)
    end)

    it("computes and caches value if not available", function()
      local c = cache.new()

      local compute_called = false
      local result = c:get_or_compute("key1", function()
        compute_called = true
        return "computed_value"
      end)

      assert.equals("computed_value", result)
      assert.is_true(compute_called)

      -- Second call should use cached value
      compute_called = false
      result = c:get_or_compute("key1", function()
        compute_called = true
        return "new_value"
      end)

      assert.equals("computed_value", result)
      assert.is_false(compute_called)
    end)
  end)

  describe("new_persistent()", function()
    it("creates cache that never expires", function()
      local c = cache.new_persistent()
      assert.equals(math.huge, c.ttl_ms)
    end)
  end)
end)
