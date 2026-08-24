-- tests/yoda/core/linter_registry_spec.lua
-- Covers the contribution point opt-in language extras use to add linters
-- and per-filetype linter lists to nvim-lint without editing the core
-- nvim-lint spec.

local registry = require("yoda.core.linter_registry")

describe("core.linter_registry", function()
  before_each(function()
    registry._reset()
  end)

  after_each(function()
    registry._reset()
  end)

  it("starts empty", function()
    -- Assert
    assert.same({}, registry.linters_by_ft())
    assert.same({}, registry.linters())
  end)

  it("collects per-filetype linter lists", function()
    -- Act
    registry.register({
      linters_by_ft = { kotlin = { "ktlint" } },
    })

    -- Assert
    assert.same({ kotlin = { "ktlint" } }, registry.linters_by_ft())
  end)

  it("collects custom linter definitions", function()
    -- Act: for a linter not in nvim-lint's built-in registry (or one that
    -- needs a project-specific config path), extras supply the full spec.
    registry.register({
      linters = {
        phpcs = {
          cmd = "phpcs",
          stdin = false,
          args = { "--report=json" },
        },
      },
    })

    -- Assert
    assert.equals("phpcs", registry.linters().phpcs.cmd)
    assert.same({ "--report=json" }, registry.linters().phpcs.args)
  end)

  it(
    "concatenates per-filetype lists when two extras target the same ft",
    function()
      -- Arrange
      registry.register({ linters_by_ft = { php = { "phpcs" } } })

      -- Act
      registry.register({ linters_by_ft = { php = { "phpstan" } } })

      -- Assert
      assert.same({ php = { "phpcs", "phpstan" } }, registry.linters_by_ft())
    end
  )

  it("de-duplicates a linter registered twice for the same filetype", function()
    -- Arrange
    registry.register({ linters_by_ft = { php = { "phpcs" } } })

    -- Act
    registry.register({ linters_by_ft = { php = { "phpcs" } } })

    -- Assert
    assert.same({ php = { "phpcs" } }, registry.linters_by_ft())
  end)

  it("first custom-linter definition wins on collision", function()
    -- Arrange
    registry.register({
      linters = { phpcs = { cmd = "/opt/one/phpcs" } },
    })

    -- Act
    registry.register({
      linters = { phpcs = { cmd = "/opt/two/phpcs" } },
    })

    -- Assert
    assert.equals("/opt/one/phpcs", registry.linters().phpcs.cmd)
  end)

  it("accepts a registration carrying only one of the two maps", function()
    -- Act
    registry.register({ linters_by_ft = { yaml = { "yamllint" } } })

    -- Assert
    assert.same({ yaml = { "yamllint" } }, registry.linters_by_ft())
    assert.same({}, registry.linters())
  end)

  it("returns copies so callers cannot mutate registry state", function()
    -- Arrange
    registry.register({ linters_by_ft = { php = { "phpcs" } } })

    -- Act
    local by_ft = registry.linters_by_ft()
    by_ft.php[1] = "MUTATED"
    by_ft.injected = { "x" }

    -- Assert
    assert.same({ php = { "phpcs" } }, registry.linters_by_ft())
  end)

  it("rejects a non-table registration", function()
    -- Act / Assert
    assert.has_error(function()
      registry.register("phpcs")
    end)
  end)
end)
