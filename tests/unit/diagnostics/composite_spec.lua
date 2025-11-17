-- Tests for diagnostics/composite.lua
local Composite = require("yoda-diagnostics.composite")

describe("diagnostics.composite", function()
  -- Helper to create mock diagnostic
  local function create_mock_diagnostic(name, status, is_critical)
    return {
      name = name,
      critical = is_critical,
      check_status = function()
        return status
      end,
      get_name = function()
        return name
      end,
    }
  end

  describe("new()", function()
    it("creates composite instance", function()
      local composite = Composite:new()
      assert.is_not_nil(composite)
      assert.is_table(composite)
    end)

    it("starts with empty diagnostics", function()
      local composite = Composite:new()
      assert.equals(0, #composite.diagnostics)
    end)
  end)

  describe("add()", function()
    it("adds diagnostic to composite", function()
      local composite = Composite:new()
      local diagnostic = create_mock_diagnostic("test", true)

      composite:add(diagnostic)
      assert.equals(1, #composite.diagnostics)
    end)

    it("returns self for chaining", function()
      local composite = Composite:new()
      local diagnostic = create_mock_diagnostic("test", true)

      local result = composite:add(diagnostic)
      assert.equals(composite, result)
    end)

    it("validates diagnostic is table", function()
      local ok = pcall(function()
        Composite:new():add("not a table")
      end)
      assert.is_false(ok)
    end)

    it("validates diagnostic has check_status method", function()
      local ok = pcall(function()
        Composite:new():add({ no_check_status = true })
      end)
      assert.is_false(ok)
    end)

    it("allows chaining multiple adds", function()
      local composite =
        Composite:new():add(create_mock_diagnostic("d1", true)):add(create_mock_diagnostic("d2", true)):add(create_mock_diagnostic("d3", true))

      assert.equals(3, #composite.diagnostics)
    end)
  end)

  describe("run_all()", function()
    it("runs all diagnostics and collects results", function()
      local composite = Composite:new():add(create_mock_diagnostic("lsp", true)):add(create_mock_diagnostic("ai", false))

      local results = composite:run_all()
      assert.is_true(results.lsp)
      assert.is_false(results.ai)
    end)

    it("returns empty table for empty composite", function()
      local composite = Composite:new()
      local results = composite:run_all()
      assert.same({}, results)
    end)

    it("stops on failure when stop_on_failure is true", function()
      local call_count = 0

      local d1 = create_mock_diagnostic("d1", true)
      local d2 = create_mock_diagnostic("d2", false)
      local d3 = {
        check_status = function()
          call_count = call_count + 1
          return true
        end,
        get_name = function()
          return "d3"
        end,
      }

      local composite = Composite:new():add(d1):add(d2):add(d3)
      composite:run_all({ stop_on_failure = true })

      assert.equals(0, call_count) -- d3 should not run
    end)

    it("continues on failure by default", function()
      local call_count = 0

      local d1 = create_mock_diagnostic("d1", true)
      local d2 = create_mock_diagnostic("d2", false)
      local d3 = {
        check_status = function()
          call_count = call_count + 1
          return true
        end,
        get_name = function()
          return "d3"
        end,
      }

      local composite = Composite:new():add(d1):add(d2):add(d3)
      composite:run_all()

      assert.equals(1, call_count) -- d3 should run
    end)
  end)

  describe("run_critical()", function()
    it("runs only critical diagnostics", function()
      local composite = Composite
        :new()
        :add(create_mock_diagnostic("d1", true, true)) -- critical
        :add(create_mock_diagnostic("d2", true, false)) -- not critical
        :add(create_mock_diagnostic("d3", true, true)) -- critical

      local results = composite:run_critical()
      assert.is_true(results.d1)
      assert.is_nil(results.d2) -- Not run
      assert.is_true(results.d3)
    end)

    it("returns empty when no critical diagnostics", function()
      local composite = Composite:new():add(create_mock_diagnostic("d1", true, false))

      local results = composite:run_critical()
      assert.same({}, results)
    end)
  end)

  describe("count()", function()
    it("returns number of diagnostics", function()
      local composite = Composite:new():add(create_mock_diagnostic("d1", true)):add(create_mock_diagnostic("d2", true))

      assert.equals(2, composite:count())
    end)

    it("returns 0 for empty composite", function()
      local composite = Composite:new()
      assert.equals(0, composite:count())
    end)
  end)

  describe("all_pass()", function()
    it("returns true when all pass", function()
      local composite = Composite:new():add(create_mock_diagnostic("d1", true)):add(create_mock_diagnostic("d2", true))

      assert.is_true(composite:all_pass())
    end)

    it("returns false when any fails", function()
      local composite = Composite:new():add(create_mock_diagnostic("d1", true)):add(create_mock_diagnostic("d2", false))

      assert.is_false(composite:all_pass())
    end)

    it("returns true for empty composite", function()
      local composite = Composite:new()
      assert.is_true(composite:all_pass())
    end)
  end)

  describe("get_aggregate_status()", function()
    it("calculates aggregate statistics", function()
      local composite =
        Composite:new():add(create_mock_diagnostic("d1", true)):add(create_mock_diagnostic("d2", false)):add(create_mock_diagnostic("d3", true))

      local stats = composite:get_aggregate_status()
      assert.equals(3, stats.total)
      assert.equals(2, stats.passed)
      assert.equals(1, stats.failed)
      assert.equals(2 / 3, stats.pass_rate)
    end)

    it("handles empty composite", function()
      local composite = Composite:new()
      local stats = composite:get_aggregate_status()

      assert.equals(0, stats.total)
      assert.equals(0, stats.passed)
      assert.equals(0, stats.failed)
      assert.equals(0, stats.pass_rate)
    end)

    it("handles all passing", function()
      local composite = Composite:new():add(create_mock_diagnostic("d1", true)):add(create_mock_diagnostic("d2", true))

      local stats = composite:get_aggregate_status()
      assert.equals(2, stats.passed)
      assert.equals(0, stats.failed)
      assert.equals(1.0, stats.pass_rate)
    end)

    it("handles all failing", function()
      local composite = Composite:new():add(create_mock_diagnostic("d1", false)):add(create_mock_diagnostic("d2", false))

      local stats = composite:get_aggregate_status()
      assert.equals(0, stats.passed)
      assert.equals(2, stats.failed)
      assert.equals(0, stats.pass_rate)
    end)
  end)

  describe("check_status() - Composite as Diagnostic", function()
    it("acts as single diagnostic (passes when all pass)", function()
      local composite = Composite:new():add(create_mock_diagnostic("d1", true)):add(create_mock_diagnostic("d2", true))

      assert.is_true(composite:check_status())
    end)

    it("fails when any sub-diagnostic fails", function()
      local composite = Composite:new():add(create_mock_diagnostic("d1", true)):add(create_mock_diagnostic("d2", false))

      assert.is_false(composite:check_status())
    end)

    it("allows nesting composites", function()
      local sub_composite = Composite:new():add(create_mock_diagnostic("d1", true)):add(create_mock_diagnostic("d2", true))

      local main_composite = Composite:new():add(sub_composite)

      assert.is_true(main_composite:check_status())
    end)
  end)

  describe("get_name()", function()
    it("returns composite name", function()
      local composite = Composite:new()
      assert.equals("Composite Diagnostic", composite:get_name())
    end)
  end)
end)
