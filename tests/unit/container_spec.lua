-- Tests for container.lua (DI container)
local Container = require("yoda.container")

describe("container", function()
  before_each(function()
    Container.reset()
  end)

  describe("register()", function()
    it("registers a service factory", function()
      Container.register("test_service", function()
        return { value = "test" }
      end)

      assert.is_true(Container.has("test_service"))
    end)

    it("validates service name is string", function()
      local ok = pcall(function()
        Container.register(123, function() end)
      end)
      assert.is_false(ok)
    end)

    it("validates service name is not empty", function()
      local ok = pcall(function()
        Container.register("", function() end)
      end)
      assert.is_false(ok)
    end)

    it("validates factory is a function", function()
      local ok = pcall(function()
        Container.register("test", "not a function")
      end)
      assert.is_false(ok)
    end)

    it("prevents registration after sealing", function()
      Container.seal()

      local ok = pcall(function()
        Container.register("test", function() end)
      end)
      assert.is_false(ok)
    end)
  end)

  describe("resolve()", function()
    it("resolves registered service", function()
      Container.register("logger", function()
        return {
          log = function(msg)
            return msg
          end,
        }
      end)

      local logger = Container.resolve("logger")
      assert.is_not_nil(logger)
      assert.equals("function", type(logger.log))
    end)

    it("caches service instances (singleton)", function()
      local call_count = 0

      Container.register("counter", function()
        call_count = call_count + 1
        return { count = call_count }
      end)

      local instance1 = Container.resolve("counter")
      local instance2 = Container.resolve("counter")

      assert.equals(instance1, instance2)
      assert.equals(1, call_count) -- Factory called only once
    end)

    it("errors on unknown service", function()
      local ok = pcall(function()
        Container.resolve("unknown_service")
      end)
      assert.is_false(ok)
    end)

    it("validates service name is string", function()
      local ok = pcall(function()
        Container.resolve(123)
      end)
      assert.is_false(ok)
    end)

    it("allows factories to resolve other services", function()
      Container.register("logger", function()
        return {
          log = function(msg)
            return msg
          end,
        }
      end)

      Container.register("app", function()
        local logger = Container.resolve("logger")
        return {
          run = function()
            return logger.log("running")
          end,
        }
      end)

      local app = Container.resolve("app")
      assert.equals("running", app.run())
    end)
  end)

  describe("has()", function()
    it("returns true for registered service", function()
      Container.register("test", function()
        return {}
      end)
      assert.is_true(Container.has("test"))
    end)

    it("returns false for unregistered service", function()
      assert.is_false(Container.has("unknown"))
    end)
  end)

  describe("seal()", function()
    it("seals container", function()
      Container.seal()

      local ok = pcall(function()
        Container.register("test", function() end)
      end)
      assert.is_false(ok)
    end)

    it("does not affect resolving", function()
      Container.register("test", function()
        return { value = 42 }
      end)

      Container.seal()

      local service = Container.resolve("test")
      assert.equals(42, service.value)
    end)
  end)

  describe("evict()", function()
    it("removes cached instance so next resolve re-instantiates", function()
      local call_count = 0

      Container.register("counter", function()
        call_count = call_count + 1
        return { count = call_count }
      end)

      local instance1 = Container.resolve("counter")
      assert.equals(1, call_count)

      Container.evict("counter")

      local instance2 = Container.resolve("counter")
      assert.equals(2, call_count)
      assert.not_equals(instance1, instance2)
    end)

    it("preserves the factory after eviction", function()
      Container.register("svc", function()
        return { value = math.random() }
      end)

      Container.resolve("svc")
      Container.evict("svc")

      -- Factory still registered, resolve succeeds
      assert.is_true(Container.has("svc"))
      local ok = pcall(Container.resolve, "svc")
      assert.is_true(ok)
    end)

    it("is a no-op when service was never resolved", function()
      Container.register("svc", function()
        return {}
      end)

      -- Should not error even though the cache is empty
      local ok = pcall(Container.evict, "svc")
      assert.is_true(ok)
    end)

    it("validates service name is non-empty string", function()
      local ok1 = pcall(Container.evict, "")
      local ok2 = pcall(Container.evict, 123)
      assert.is_false(ok1)
      assert.is_false(ok2)
    end)

    it("does not clear other cached services", function()
      local count_a, count_b = 0, 0

      Container.register("a", function()
        count_a = count_a + 1
        return { n = count_a }
      end)
      Container.register("b", function()
        count_b = count_b + 1
        return { n = count_b }
      end)

      Container.resolve("a")
      Container.resolve("b")

      Container.evict("a")

      Container.resolve("a")
      Container.resolve("b") -- should still be cached

      assert.equals(2, count_a) -- re-instantiated
      assert.equals(1, count_b) -- still cached
    end)
  end)

  describe("reset()", function()
    it("clears all services", function()
      Container.register("test", function()
        return {}
      end)
      Container.resolve("test")

      Container.reset()

      assert.is_false(Container.has("test"))
    end)

    it("unseals container", function()
      Container.seal()
      Container.reset()

      -- Should not error
      Container.register("test", function()
        return {}
      end)
      assert.is_true(Container.has("test"))
    end)
  end)

  describe("bootstrap()", function()
    it("registers all core services", function()
      Container.bootstrap()

      -- Check core services registered
      assert.is_true(Container.has("core.io"))
      assert.is_true(Container.has("core.platform"))
      assert.is_true(Container.has("core.string"))
      assert.is_true(Container.has("core.table"))
    end)

    it("registers adapter services", function()
      Container.bootstrap()

      assert.is_true(Container.has("adapters.notification"))
      assert.is_true(Container.has("adapters.picker"))
    end)

    it("registers terminal services", function()
      Container.bootstrap()

      assert.is_true(Container.has("terminal"))
      assert.is_true(Container.has("terminal.config"))
      assert.is_true(Container.has("terminal.shell"))
      assert.is_true(Container.has("terminal.venv"))
      assert.is_true(Container.has("terminal.builder"))
    end)

    it("registers diagnostics services", function()
      Container.bootstrap()

      assert.is_true(Container.has("diagnostics"))
      assert.is_true(Container.has("diagnostics.lsp"))
      assert.is_true(Container.has("diagnostics.ai"))
      assert.is_true(Container.has("diagnostics.ai_cli"))
      assert.is_true(Container.has("diagnostics.composite"))
    end)

    it("seals container after bootstrap", function()
      Container.bootstrap()

      local ok = pcall(function()
        Container.register("new_service", function() end)
      end)
      assert.is_false(ok)
    end)

    it("returns container for chaining", function()
      local result = Container.bootstrap()
      assert.equals(Container, result)
    end)
  end)

  describe("resolve_many()", function()
    it("resolves multiple services at once", function()
      Container.register("logger", function()
        return { log = print }
      end)
      Container.register("fs", function()
        return { read = function() end }
      end)

      local deps = Container.resolve_many({ "logger", "fs" })

      assert.is_not_nil(deps.logger)
      assert.is_not_nil(deps.fs)
      assert.equals(2, vim.tbl_count(deps))
    end)

    it("returns empty table for empty array", function()
      local deps = Container.resolve_many({})
      assert.same({}, deps)
    end)
  end)

  describe("integration", function()
    it("supports full dependency graph", function()
      -- Reset and build fresh
      Container.reset()

      -- Register in dependency order
      Container.register("logger", function()
        return {
          info = function(msg)
            return "INFO: " .. msg
          end,
        }
      end)

      Container.register("database", function()
        local logger = Container.resolve("logger")
        return {
          query = function(sql)
            logger.info("Executing: " .. sql)
            return { result = "success" }
          end,
        }
      end)

      Container.register("app", function()
        local db = Container.resolve("database")
        return {
          run = function()
            return db.query("SELECT * FROM users")
          end,
        }
      end)

      -- Resolve and use
      local app = Container.resolve("app")
      local result = app.run()

      assert.equals("success", result.result)
    end)
  end)
end)
