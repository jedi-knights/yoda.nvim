-- Tests for core/table.lua
local tbl = require("yoda-core.table")

describe("core.table", function()
  describe("merge()", function()
    it("merges two tables", function()
      local defaults = { x = 1, y = 2 }
      local overrides = { y = 3, z = 4 }
      local result = tbl.merge(defaults, overrides)

      assert.equals(1, result.x)
      assert.equals(3, result.y) -- Override wins
      assert.equals(4, result.z)
    end)

    it("handles empty overrides", function()
      local defaults = { x = 1, y = 2 }
      local result = tbl.merge(defaults, {})

      assert.equals(1, result.x)
      assert.equals(2, result.y)
    end)

    it("handles nil overrides", function()
      local defaults = { x = 1, y = 2 }
      local result = tbl.merge(defaults, nil)

      assert.equals(1, result.x)
      assert.equals(2, result.y)
    end)

    it("handles empty defaults", function()
      local overrides = { x = 1 }
      local result = tbl.merge({}, overrides)

      assert.equals(1, result.x)
    end)

    it("handles non-table defaults", function()
      local overrides = { x = 1 }
      local result = tbl.merge(nil, overrides)

      assert.equals(1, result.x)
    end)

    it("does not modify original tables", function()
      local defaults = { x = 1 }
      local overrides = { y = 2 }
      local result = tbl.merge(defaults, overrides)

      result.z = 3

      assert.is_nil(defaults.z)
      assert.is_nil(overrides.z)
    end)

    it("handles nested tables (shallow copy)", function()
      local defaults = { nested = { a = 1 } }
      local overrides = { nested = { b = 2 } }
      local result = tbl.merge(defaults, overrides)

      -- Override completely replaces nested table
      assert.is_nil(result.nested.a)
      assert.equals(2, result.nested.b)
    end)

    it("handles boolean values", function()
      local defaults = { flag = false }
      local overrides = { flag = true }
      local result = tbl.merge(defaults, overrides)

      assert.is_true(result.flag)
    end)

    it("handles array-like tables", function()
      local defaults = { 1, 2, 3 }
      local overrides = { [2] = 99 }
      local result = tbl.merge(defaults, overrides)

      assert.equals(1, result[1])
      assert.equals(99, result[2])
      assert.equals(3, result[3])
    end)
  end)

  describe("deep_copy()", function()
    it("creates independent copy of simple table", function()
      local original = { x = 1, y = 2 }
      local copy = tbl.deep_copy(original)

      copy.x = 99

      assert.equals(1, original.x) -- Original unchanged
      assert.equals(99, copy.x)
    end)

    it("creates independent copy of nested table", function()
      local original = { a = { b = 1 } }
      local copy = tbl.deep_copy(original)

      copy.a.b = 99

      assert.equals(1, original.a.b) -- Original unchanged
      assert.equals(99, copy.a.b)
    end)

    it("handles deeply nested tables", function()
      local original = { a = { b = { c = { d = 1 } } } }
      local copy = tbl.deep_copy(original)

      copy.a.b.c.d = 99

      assert.equals(1, original.a.b.c.d)
      assert.equals(99, copy.a.b.c.d)
    end)

    it("handles arrays", function()
      local original = { 1, 2, 3 }
      local copy = tbl.deep_copy(original)

      copy[1] = 99

      assert.equals(1, original[1])
      assert.equals(99, copy[1])
    end)

    it("handles mixed keys", function()
      local original = { 1, 2, x = "a", y = "b" }
      local copy = tbl.deep_copy(original)

      copy[1] = 99
      copy.x = "z"

      assert.equals(1, original[1])
      assert.equals("a", original.x)
      assert.equals(99, copy[1])
      assert.equals("z", copy.x)
    end)

    it("handles nil values in table", function()
      local original = { a = 1, b = nil, c = 3 }
      local copy = tbl.deep_copy(original)

      assert.equals(1, copy.a)
      assert.is_nil(copy.b)
      assert.equals(3, copy.c)
    end)

    it("handles non-table values", function()
      assert.equals(42, tbl.deep_copy(42))
      assert.equals("hello", tbl.deep_copy("hello"))
      assert.is_true(tbl.deep_copy(true))
      assert.is_nil(tbl.deep_copy(nil))
    end)

    it("handles empty table", function()
      local original = {}
      local copy = tbl.deep_copy(original)

      assert.same({}, copy)
      assert.is_not.equal(original, copy) -- Different instances
    end)

    it("copies metatables", function()
      local mt = { __index = { default = "value" } }
      local original = setmetatable({ x = 1 }, mt)
      local copy = tbl.deep_copy(original)

      assert.equals("value", copy.default) -- Metatable preserved
      assert.equals(1, copy.x)
    end)

    it("handles tables with table keys", function()
      local key = { a = 1 }
      local original = { [key] = "value" }
      local copy = tbl.deep_copy(original)

      -- Find the copied key
      local found = false
      for k, v in pairs(copy) do
        if type(k) == "table" and k.a == 1 then
          found = true
          assert.equals("value", v)
        end
      end
      assert.is_true(found)
    end)
  end)

  describe("is_empty()", function()
    it("returns true for empty table", function()
      assert.is_true(tbl.is_empty({}))
    end)

    it("returns false for non-empty table", function()
      assert.is_false(tbl.is_empty({ x = 1 }))
      assert.is_false(tbl.is_empty({ 1 }))
    end)

    it("returns false for array with one element", function()
      assert.is_false(tbl.is_empty({ 1 }))
    end)

    it("returns false for table with nil values but keys present", function()
      -- Note: Lua tables don't store nil values
      local t = { a = 1, b = nil }
      assert.is_false(tbl.is_empty(t))
    end)

    it("handles non-table values", function()
      assert.is_true(tbl.is_empty(nil))
      assert.is_true(tbl.is_empty("string"))
      assert.is_true(tbl.is_empty(42))
      assert.is_true(tbl.is_empty(true))
    end)

    it("handles table with false value", function()
      assert.is_false(tbl.is_empty({ false }))
      assert.is_false(tbl.is_empty({ x = false }))
    end)
  end)

  describe("size()", function()
    it("returns 0 for empty table", function()
      assert.equals(0, tbl.size({}))
    end)

    it("returns correct size for simple table", function()
      assert.equals(3, tbl.size({ x = 1, y = 2, z = 3 }))
    end)

    it("returns correct size for array", function()
      assert.equals(3, tbl.size({ 1, 2, 3 }))
    end)

    it("returns correct size for mixed table", function()
      assert.equals(5, tbl.size({ 1, 2, 3, x = "a", y = "b" }))
    end)

    it("returns 0 for non-table values", function()
      assert.equals(0, tbl.size(nil))
      assert.equals(0, tbl.size("string"))
      assert.equals(0, tbl.size(42))
      assert.equals(0, tbl.size(true))
    end)

    it("handles nested tables (counts only top level)", function()
      local t = {
        a = { b = { c = 1 } },
        x = { y = 2 },
        z = 3,
      }
      assert.equals(3, tbl.size(t))
    end)

    it("handles tables with false values", function()
      assert.equals(2, tbl.size({ false, true }))
      assert.equals(2, tbl.size({ x = false, y = true }))
    end)

    it("does not count nil values", function()
      -- Lua doesn't store nil values in tables
      local t = { a = 1, b = 2 }
      t.c = nil
      assert.equals(2, tbl.size(t))
    end)
  end)

  describe("contains()", function()
    it("returns true when value exists", function()
      assert.is_true(tbl.contains({ 1, 2, 3 }, 2))
      assert.is_true(tbl.contains({ x = "a", y = "b" }, "a"))
    end)

    it("returns false when value does not exist", function()
      assert.is_false(tbl.contains({ 1, 2, 3 }, 4))
      assert.is_false(tbl.contains({ x = "a" }, "b"))
    end)

    it("returns false for empty table", function()
      assert.is_false(tbl.contains({}, "anything"))
    end)

    it("handles string values", function()
      assert.is_true(tbl.contains({ "a", "b", "c" }, "b"))
      assert.is_false(tbl.contains({ "a", "b", "c" }, "d"))
    end)

    it("handles numeric values", function()
      assert.is_true(tbl.contains({ 1, 2, 3 }, 2))
      assert.is_false(tbl.contains({ 1, 2, 3 }, 4))
    end)

    it("handles boolean values", function()
      assert.is_true(tbl.contains({ true, false }, true))
      assert.is_true(tbl.contains({ true, false }, false))
    end)

    it("handles nil search value", function()
      -- Lua tables can't contain nil values
      assert.is_false(tbl.contains({ 1, 2, 3 }, nil))
    end)

    it("checks values not keys", function()
      local t = { a = 1, b = 2, c = 3 }
      assert.is_true(tbl.contains(t, 1))
      assert.is_true(tbl.contains(t, 2))
      assert.is_false(tbl.contains(t, "a")) -- "a" is a key, not a value
    end)

    it("uses equality not identity", function()
      assert.is_true(tbl.contains({ "hello" }, "hello"))
    end)

    it("handles tables as values (identity check)", function()
      local subtable = { x = 1 }
      local t = { subtable, { y = 2 } }
      assert.is_true(tbl.contains(t, subtable))
      assert.is_false(tbl.contains(t, { x = 1 })) -- Different instance
    end)

    it("returns false for non-table input", function()
      assert.is_false(tbl.contains(nil, "value"))
      assert.is_false(tbl.contains("string", "value"))
      assert.is_false(tbl.contains(42, "value"))
    end)

    it("handles mixed type tables", function()
      local t = { 1, "two", true, { nested = "table" } }
      assert.is_true(tbl.contains(t, 1))
      assert.is_true(tbl.contains(t, "two"))
      assert.is_true(tbl.contains(t, true))
    end)
  end)
end)
