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
      assert.has_no.errors(function()
        spec.config()
      end, spec.name)
    end
  end)
end)
