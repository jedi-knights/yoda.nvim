-- tests/yoda/plugins/neotest_core_spec.lua
local helpers = require("tests.helpers")

describe("plugins.neotest-core", function()
  local specs
  local neotest_registry = require("yoda.core.neotest_registry")

  local function by_name(name)
    for _, spec in ipairs(specs) do
      if spec[1] == name then
        return spec
      end
    end
    return nil
  end

  before_each(function()
    package.loaded["yoda.plugins.neotest-core"] = nil
    specs = require("yoda.plugins.neotest-core")
    neotest_registry._reset()
  end)

  after_each(function()
    package.loaded["neotest-plenary"] = nil
    package.loaded.neotest = nil
    package.loaded.coverage = nil
    neotest_registry._reset()
  end)

  it("declares neotest and nvim-coverage, both cmd-triggered", function()
    -- Assert
    local neotest_spec = by_name("nvim-neotest/neotest")
    local coverage_spec = by_name("andythigpen/nvim-coverage")
    assert.is_not_nil(neotest_spec)
    assert.same(
      { "Neotest", "NeotestRun", "NeotestSummary", "NeotestOutput" },
      neotest_spec.cmd
    )
    assert.is_not_nil(coverage_spec)
    assert.same(
      { "Coverage", "CoverageLoad", "CoverageShow", "CoverageHide" },
      coverage_spec.cmd
    )
  end)

  describe("neotest config()", function()
    local neotest_spec

    before_each(function()
      neotest_spec = by_name("nvim-neotest/neotest")
    end)

    it(
      "warns about the missing plenary adapter, then raises when neotest itself is unavailable",
      function()
        -- Arrange
        local notify_spy, notify_data = helpers.spy()
        local restore = helpers.mock(vim, "notify", notify_spy)

        -- Act
        local ok = pcall(neotest_spec.config)

        -- Assert: the plenary-adapter pcall is genuinely protective (it
        -- notifies and continues), but registry.setup() -> _apply_setup()
        -- does `pcall(require("neotest").setup, ...)` -- the same
        -- argument-evaluation-order bug as nvim-coverage's config() below:
        -- require("neotest") runs while resolving pcall's argument, outside
        -- pcall's own protection, so it raises uncaught here. Characterizing
        -- the actual behavior, not the intended one -- see the finding noted
        -- in this PR's description.
        assert.is_false(ok)
        local found_plenary_warning = false
        for _, call in ipairs(notify_data.calls) do
          if call[1]:find("neotest%-plenary not available") then
            found_plenary_warning = true
          end
        end
        assert.is_true(found_plenary_warning)

        restore()
      end
    )

    it("registers the plenary adapter when available", function()
      -- Arrange
      package.loaded["neotest-plenary"] = {}
      package.loaded.neotest = { setup = function() end }

      -- Act
      neotest_spec.config()

      -- Assert
      assert.equals(1, #neotest_registry.adapters())
    end)

    it(
      "passes through the summary/output/icon configuration without error",
      function()
        -- Arrange
        local setup_spy, setup_data = helpers.spy()
        package.loaded.neotest = { setup = setup_spy }

        -- Act
        neotest_spec.config()

        -- Assert
        helpers.assert_called(setup_data, 1)
        local passed_opts = setup_data.last_call[1]
        assert.is_true(passed_opts.output.enabled)
        assert.is_true(passed_opts.summary.enabled)
        assert.equals("✓", passed_opts.icons.passed)
      end
    )
  end)

  describe("nvim-coverage config()", function()
    local coverage_spec

    before_each(function()
      coverage_spec = by_name("andythigpen/nvim-coverage")
    end)

    it(
      "raises when nvim-coverage is unavailable -- pcall does not protect require()",
      function()
        -- pcall(require("coverage").setup) evaluates require("coverage")
        -- while resolving the argument to pcall, outside pcall's own
        -- protection -- a pre-existing latent bug (should be
        -- pcall(function() require("coverage").setup() end)), not
        -- something to paper over here.
        assert.is_false(pcall(coverage_spec.config))
      end
    )

    it("notifies an error when coverage.setup() itself raises", function()
      -- Arrange
      package.loaded.coverage = {
        setup = function()
          error("boom")
        end,
      }
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      coverage_spec.config()

      -- Assert
      assert.matches("%[coverage%] setup failed", notify_data.last_call[1])

      restore()
    end)

    it("does not notify when coverage.setup() succeeds", function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      package.loaded.coverage = { setup = setup_spy }
      local notify_spy, notify_data = helpers.spy()
      local restore = helpers.mock(vim, "notify", notify_spy)

      -- Act
      coverage_spec.config()

      -- Assert
      helpers.assert_called(setup_data, 1)
      helpers.assert_not_called(notify_data)

      restore()
    end)
  end)
end)
