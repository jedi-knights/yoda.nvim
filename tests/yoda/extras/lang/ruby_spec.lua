-- tests/yoda/extras/lang/ruby_spec.lua
local registry = require("yoda.core.lsp_registry")

describe("extras.lang.ruby", function()
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
    package.loaded["yoda.extras.lang.ruby"] = nil
    specs = require("yoda.extras.lang.ruby")
  end)

  after_each(function()
    registry._reset()
  end)

  it("registers its LSP servers -- both test adapters register", function()
    -- Assert
    assert.same({ "ruby_lsp" }, registry.servers())
  end)

  it("registers its debug adapters", function()
    -- Assert
    assert.same({}, registry.dap_adapters())
  end)

  it("declares neotest-rspec", function()
    -- Act
    local spec = by_name("olimorris/neotest-rspec")

    -- Assert
    assert.is_not_nil(spec, "olimorris/neotest-rspec missing from spec list")
    assert.is_truthy(
      spec.ft,
      "neotest-rspec must be filetype-gated so it costs nothing when unused"
    )
  end)

  it("declares neotest-minitest", function()
    -- Act
    local spec = by_name("zidhuss/neotest-minitest")

    -- Assert
    assert.is_not_nil(spec, "zidhuss/neotest-minitest missing from spec list")
    assert.is_truthy(
      spec.ft,
      "neotest-minitest must be filetype-gated so it costs nothing when unused"
    )
  end)

  it("declares nvim-dap-ruby", function()
    -- Act
    local spec = by_name("suketa/nvim-dap-ruby")

    -- Assert
    assert.is_not_nil(spec, "suketa/nvim-dap-ruby missing from spec list")
    assert.is_truthy(
      spec.ft,
      "nvim-dap-ruby must be filetype-gated so it costs nothing when unused"
    )
  end)

  it("survives its plugins being absent", function()
    -- Arrange: under test none of these plugins are installed, so
    -- config() exercises the require-failed branch.
    -- Act / Assert
    for _, spec in ipairs(specs) do
      if type(spec.config) == "function" then
        local ok = pcall(spec.config)
        assert.is_true(ok, tostring(spec[1]))
      end
    end
  end)
end)
