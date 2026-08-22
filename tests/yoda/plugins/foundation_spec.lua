-- tests/yoda/plugins/foundation_spec.lua
-- Validates the first-party yoda-* sibling specs. Loaded with dofile so the
-- YODA_DEV_LOCAL branch can be exercised -- require() would cache the first
-- evaluation and pin whichever branch ran first.

describe("plugins.foundation", function()
  local specpath = vim.fn.getcwd() .. "/lua/yoda/plugins/foundation.lua"
  local original_dev_local = vim.env.YODA_DEV_LOCAL

  local EXPECTED = {
    "yoda.nvim-adapters",
    "yoda-core.nvim",
    "yoda-logging.nvim",
    "yoda-terminal.nvim",
    "yoda-window.nvim",
    "yoda-diagnostics.nvim",
  }

  local function load(dev_local)
    vim.env.YODA_DEV_LOCAL = dev_local
    return dofile(specpath)
  end

  local function by_name(specs, name)
    for _, spec in ipairs(specs) do
      if spec.name == name then
        return spec
      end
    end
    return nil
  end

  after_each(function()
    vim.env.YODA_DEV_LOCAL = original_dev_local
  end)

  it("declares every first-party sibling plugin", function()
    -- Act
    local specs = load(nil)

    -- Assert
    assert.equals(#EXPECTED, #specs)
    for _, name in ipairs(EXPECTED) do
      assert.is_not_nil(by_name(specs, name), "missing spec: " .. name)
    end
  end)

  it("resolves to the GitHub repo when not in dev-local mode", function()
    -- Act
    local specs = load(nil)

    -- Assert
    for _, spec in ipairs(specs) do
      assert.equals("jedi-knights/" .. spec.name, spec[1])
      assert.is_nil(spec.dir)
    end
  end)

  it("resolves to a local working copy when YODA_DEV_LOCAL is set", function()
    -- Act
    local specs = load("1")

    -- Assert
    for _, spec in ipairs(specs) do
      assert.is_nil(spec[1])
      -- Exact compare rather than a pattern match: repo names contain "-"
      -- and ".", both of which are Lua pattern metacharacters.
      assert.equals(
        vim.env.HOME .. "/src/github/jedi-knights/" .. spec.name,
        spec.dir
      )
    end
  end)

  it("defers every sibling to VeryLazy", function()
    -- Act
    local specs = load(nil)

    -- Assert
    for _, spec in ipairs(specs) do
      assert.equals("VeryLazy", spec.event)
    end
  end)

  it("orders the adapter-dependent siblings behind the adapters", function()
    -- Arrange
    local specs = load(nil)
    local dependents =
      { "yoda-logging.nvim", "yoda-terminal.nvim", "yoda-window.nvim" }

    -- Assert
    for _, name in ipairs(dependents) do
      local spec = by_name(specs, name)
      assert.same({ "yoda.nvim-adapters" }, spec.dependencies, name)
    end
  end)

  it("gives every sibling a config function", function()
    -- Act
    local specs = load(nil)

    -- Assert
    for _, spec in ipairs(specs) do
      assert.equals("function", type(spec.config), spec.name)
    end
  end)

  it("does not raise when a sibling module is absent", function()
    -- Arrange: none of the yoda-* siblings are installed under test, so
    -- config() exercises the require-failed branch.
    local specs = load(nil)

    -- Act / Assert
    for _, spec in ipairs(specs) do
      local ok = pcall(spec.config)
      assert.is_true(ok, spec.name)
    end
  end)

  it(
    "emits an ERROR notify when the sibling module require fails (L38)",
    function()
      -- Arrange: minimal_init preloads every yoda-* module as a stub, so a
      -- plain config() succeeds. Force yoda-adapters (the first spec's
      -- module) to fail so the L38 branch fires.
      local original_preload = package.preload["yoda-adapters"]
      local original_loaded = package.loaded["yoda-adapters"]
      package.loaded["yoda-adapters"] = nil
      package.preload["yoda-adapters"] = function()
        error("simulated adapter failure")
      end
      local specs = load(nil)
      local adapter_spec = by_name(specs, "yoda.nvim-adapters")
      assert.is_not_nil(adapter_spec)
      local notify_msgs = {}
      local original_notify = vim.notify
      vim.notify = function(msg, level)
        table.insert(notify_msgs, { msg = msg, level = level })
      end

      -- Act
      adapter_spec.config()

      -- Assert
      local found = false
      for _, entry in ipairs(notify_msgs) do
        if entry.msg:find("Failed to load yoda%-adapters") then
          found = true
          assert.equals(vim.log.levels.ERROR, entry.level)
        end
      end
      assert.is_true(found, "expected an ERROR notify for the load failure")

      vim.notify = original_notify
      package.preload["yoda-adapters"] = original_preload
      package.loaded["yoda-adapters"] = original_loaded
    end
  )

  it("emits a WARN notify when the sibling's setup() raises (L52)", function()
    -- Arrange: swap in a yoda-core stub whose setup raises.
    local original_loaded = package.loaded["yoda-core"]
    package.loaded["yoda-core"] = {
      setup = function()
        error("simulated setup failure")
      end,
    }
    local specs = load(nil)
    local core_spec = by_name(specs, "yoda-core.nvim")
    assert.is_not_nil(core_spec)
    local notify_msgs = {}
    local original_notify = vim.notify
    vim.notify = function(msg, level)
      table.insert(notify_msgs, { msg = msg, level = level })
    end

    -- Act
    core_spec.config()

    -- Assert
    local found = false
    for _, entry in ipairs(notify_msgs) do
      if entry.msg:find("yoda%-core setup failed") then
        found = true
        assert.equals(vim.log.levels.WARN, entry.level)
      end
    end
    assert.is_true(found, "expected a WARN notify for the setup failure")

    vim.notify = original_notify
    package.loaded["yoda-core"] = original_loaded
  end)
end)
