-- tests/property/core_table_properties_spec.lua
-- Property-based tests for core/table.lua

local property = require("tests.property_based")
local table_utils = require("yoda-core.table")

describe("core.table (property-based)", function()
  before_each(function()
    property.set_seed(42)
  end)

  describe("merge()", function()
    it("identity: merge(x, {}) = x", function()
      property.property("empty override is identity", { runs = 200 }, function()
        local tbl = property.gen.table(property.gen.string(1, 10, "abc"), property.gen.integer(1, 100), 1, 10)()

        local result = table_utils.merge(tbl, {})

        -- Check all keys from original are in result
        for k, v in pairs(tbl) do
          assert.equals(v, result[k], string.format("Key %s: expected %s, got %s", k, v, result[k]))
        end
      end)
    end)

    it("override wins: merge({a=1}, {a=2}).a = 2", function()
      property.property("override takes precedence", { runs = 200 }, function()
        local key = property.gen.string(1, 10, "abc")()
        local val1 = property.gen.integer(1, 100)()
        local val2 = property.gen.integer(1, 100)()

        local defaults = { [key] = val1 }
        local overrides = { [key] = val2 }

        local result = table_utils.merge(defaults, overrides)
        assert.equals(val2, result[key])
      end)
    end)

    it("commutative for disjoint tables", function()
      property.property("merge order doesn't matter for disjoint keys", { runs = 100 }, function()
        local key1 = "a_" .. property.gen.string(1, 5)()
        local key2 = "b_" .. property.gen.string(1, 5)()
        local val1 = property.gen.integer(1, 100)()
        local val2 = property.gen.integer(1, 100)()

        if key1 ~= key2 then
          local t1 = { [key1] = val1 }
          local t2 = { [key2] = val2 }

          local result1 = table_utils.merge(t1, t2)
          local result2 = table_utils.merge(t2, t1)

          assert.equals(result1[key1], result2[key1])
          assert.equals(result1[key2], result2[key2])
        end
      end)
    end)

    it("preserves all keys from both tables", function()
      property.property("all keys present", { runs = 150 }, function()
        local t1 = property.gen.table(property.gen.string(1, 5, "abc"), property.gen.integer(1, 50), 1, 5)()
        local t2 = property.gen.table(property.gen.string(1, 5, "xyz"), property.gen.integer(1, 50), 1, 5)()

        local result = table_utils.merge(t1, t2)

        -- All keys from t2 should be in result
        for k, v in pairs(t2) do
          assert.equals(v, result[k])
        end

        -- All keys from t1 that aren't in t2 should be in result
        for k, v in pairs(t1) do
          if t2[k] == nil then
            assert.equals(v, result[k])
          end
        end
      end)
    end)
  end)

  describe("deep_copy()", function()
    it("equality: deep_copy(x) equals x", function()
      property.property("copy equals original", { runs = 150 }, function()
        local tbl = property.gen.table(property.gen.string(1, 10), property.gen.integer(1, 100), 1, 10)()

        local copy = table_utils.deep_copy(tbl)

        for k, v in pairs(tbl) do
          assert.equals(v, copy[k])
        end
        for k, v in pairs(copy) do
          assert.equals(v, tbl[k])
        end
      end)
    end)

    it("independence: modifying copy doesn't affect original", function()
      property.property("copy is independent", { runs = 150 }, function()
        local tbl = property.gen.table(property.gen.string(1, 10, "abc"), property.gen.integer(1, 100), 1, 5)()

        local copy = table_utils.deep_copy(tbl)

        -- Modify copy
        local new_key = "new_" .. property.gen.string(1, 5)()
        copy[new_key] = 999

        -- Original should not have new key
        assert.is_nil(tbl[new_key])
      end)
    end)

    it("idempotence: deep_copy(deep_copy(x)) equals deep_copy(x)", function()
      property.property("double copy equals single copy", { runs = 100 }, function()
        local tbl = property.gen.table(property.gen.string(1, 10), property.gen.integer(1, 100), 1, 5)()

        local copy1 = table_utils.deep_copy(tbl)
        local copy2 = table_utils.deep_copy(copy1)

        for k, v in pairs(copy1) do
          assert.equals(v, copy2[k])
        end
      end)
    end)

    it("nested tables are also copied", function()
      property.property("nested independence", { runs = 100 }, function()
        local inner = { value = property.gen.integer(1, 100)() }
        local outer = { nested = inner }

        local copy = table_utils.deep_copy(outer)

        -- Modify nested table in copy
        copy.nested.value = 999

        -- Original nested table should be unchanged
        assert.not_equals(999, inner.value)
      end)
    end)
  end)

  describe("is_empty()", function()
    it("new table is empty", function()
      property.property("empty table detection", { runs = 50 }, function()
        local tbl = {}
        assert.is_true(table_utils.is_empty(tbl))
      end)
    end)

    it("table with elements is not empty", function()
      property.property("non-empty table detection", { runs = 150 }, function()
        local tbl = property.gen.table(property.gen.string(1, 10), property.gen.integer(1, 100), 1, 10)()

        -- Add at least one element
        if next(tbl) == nil then
          tbl["key"] = 1
        end

        assert.is_false(table_utils.is_empty(tbl))
      end)
    end)

    it("cleared table is empty", function()
      property.property("cleared table is empty", { runs = 100 }, function()
        local tbl = property.gen.table(property.gen.string(1, 10), property.gen.integer(1, 100), 1, 10)()

        -- Clear table
        for k in pairs(tbl) do
          tbl[k] = nil
        end

        assert.is_true(table_utils.is_empty(tbl))
      end)
    end)
  end)

  describe("size()", function()
    it("size of empty table is 0", function()
      property.property("empty size", { runs = 50 }, function()
        assert.equals(0, table_utils.size({}))
      end)
    end)

    it("size equals number of insertions (for unique keys)", function()
      property.property("size matches insertions", { runs = 150 }, function()
        local tbl = {}
        local count = property.gen.integer(1, 20)()

        -- Insert unique keys
        for i = 1, count do
          tbl["key" .. i] = i
        end

        assert.equals(count, table_utils.size(tbl))
      end)
    end)

    it("size never negative", function()
      property.property("size is non-negative", { runs = 200 }, function()
        local tbl = property.gen.table(property.gen.string(1, 10), property.gen.integer(1, 100), 0, 10)()

        assert.is_true(table_utils.size(tbl) >= 0)
      end)
    end)

    it("removing element decreases size by 1", function()
      property.property("removal decreases size", { runs = 150 }, function()
        local tbl = property.gen.table(property.gen.string(1, 10, "abc"), property.gen.integer(1, 100), 1, 10)()

        local original_size = table_utils.size(tbl)

        -- Remove one key
        local key_to_remove = next(tbl)
        if key_to_remove then
          tbl[key_to_remove] = nil
          assert.equals(original_size - 1, table_utils.size(tbl))
        end
      end)
    end)
  end)

  describe("contains()", function()
    it("empty table contains nothing", function()
      property.property("empty contains nothing", { runs = 100 }, function()
        local value = property.gen.integer(1, 100)()
        assert.is_false(table_utils.contains({}, value))
      end)
    end)

    it("inserted value is contained", function()
      property.property("insert then contains", { runs = 200 }, function()
        local value = property.gen.integer(1, 1000)()
        local tbl = { value }

        assert.is_true(table_utils.contains(tbl, value))
      end)
    end)

    it("monotonicity: if contains(t, v) then contains(t ∪ {x}, v)", function()
      property.property("adding elements preserves containment", { runs = 150 }, function()
        local value = property.gen.integer(1, 100)()
        local tbl = { value }

        -- Add another element
        local new_value = property.gen.integer(1, 100)()
        table.insert(tbl, new_value)

        -- Original value should still be contained
        assert.is_true(table_utils.contains(tbl, value))
      end)
    end)

    it("removed value is not contained", function()
      property.property("remove then not contains", { runs = 150 }, function()
        local value = property.gen.integer(1, 1000)()
        local tbl = { value }

        -- Remove the value
        tbl[1] = nil

        assert.is_false(table_utils.contains(tbl, value))
      end)
    end)
  end)

  -- Advanced: Test algebraic properties
  describe("algebraic properties", function()
    it("merge associativity: merge(merge(a, b), c) ≈ merge(a, merge(b, c))", function()
      property.property("merge is associative for disjoint keys", { runs = 100 }, function()
        -- Use prefixes to ensure disjoint keys
        local t1 = { a1 = property.gen.integer(1, 100)() }
        local t2 = { b1 = property.gen.integer(1, 100)() }
        local t3 = { c1 = property.gen.integer(1, 100)() }

        local result1 = table_utils.merge(table_utils.merge(t1, t2), t3)
        local result2 = table_utils.merge(t1, table_utils.merge(t2, t3))

        -- Check all keys have same values
        for k, v in pairs(result1) do
          assert.equals(v, result2[k])
        end
        for k, v in pairs(result2) do
          assert.equals(v, result1[k])
        end
      end)
    end)

    it("size is additive for disjoint tables", function()
      property.property("size(merge(a, b)) = size(a) + size(b) for disjoint tables", { runs = 100 }, function()
        -- Create tables with prefixed keys to ensure disjoint
        local t1 = {}
        local t2 = {}
        local size1 = property.gen.integer(1, 5)()
        local size2 = property.gen.integer(1, 5)()

        for i = 1, size1 do
          t1["a" .. i] = i
        end
        for i = 1, size2 do
          t2["b" .. i] = i
        end

        local merged = table_utils.merge(t1, t2)
        assert.equals(size1 + size2, table_utils.size(merged))
      end)
    end)
  end)

  -- Statistics
  describe("generator statistics", function()
    it("table size distribution", function()
      property.classify("Table sizes", property.gen.table(property.gen.string(1, 10), property.gen.integer(1, 100), 0, 20), function(t)
        local size = table_utils.size(t)
        if size == 0 then
          return "empty"
        elseif size < 5 then
          return "small"
        elseif size < 15 then
          return "medium"
        else
          return "large"
        end
      end, 500)
    end)
  end)
end)
