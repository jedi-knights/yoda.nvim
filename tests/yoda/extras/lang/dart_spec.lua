-- tests/yoda/extras/lang/dart_spec.lua
local registry = require("yoda.core.lsp_registry")

describe("extras.lang.dart", function()
  local specs

  local function by_name(plugin)
    for _, spec in ipairs(specs) do
      if spec[1] == plugin then
        return spec
      end
    end
    return nil
  end

  before_each(function()
    registry._reset()
    package.loaded["yoda.extras.lang.dart"] = nil
    specs = require("yoda.extras.lang.dart")
  end)

  after_each(function()
    registry._reset()
  end)

  it(
    "does NOT register dartls with Mason -- managed by flutter-tools",
    function()
      -- Assert: flutter-tools.nvim owns dartls setup, hot-reload, device
      -- selection and DAP. Registering dartls here too would double-configure
      -- the server.
      assert.same({}, registry.servers())
      assert.same({}, registry.dap_adapters())
    end
  )

  it("declares flutter-tools.nvim, filetype-gated to *.dart", function()
    -- Act
    local spec = by_name("nvim-flutter/flutter-tools.nvim")

    -- Assert
    assert.is_not_nil(spec, "nvim-flutter/flutter-tools.nvim missing")
    assert.equals("dart", spec.ft)
    -- flutter-tools calls into plenary; it must be declared as a dependency
    -- so lazy.nvim orders the load correctly.
    assert.is_truthy(spec.dependencies)
    local has_plenary = false
    for _, dep in ipairs(spec.dependencies) do
      if dep == "nvim-lua/plenary.nvim" then
        has_plenary = true
      end
    end
    assert.is_true(
      has_plenary,
      "flutter-tools depends on plenary; declare it explicitly"
    )
  end)

  it("survives its plugins being absent", function()
    -- Arrange / Act / Assert: under test flutter-tools is not installed, so
    -- config() exercises the require-failed branch.
    for _, spec in ipairs(specs) do
      if type(spec.config) == "function" then
        local ok = pcall(spec.config)
        assert.is_true(ok, tostring(spec[1]))
      end
    end
  end)
end)
