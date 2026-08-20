-- tests/yoda/plugins/util_spec.lua

describe("plugins.util", function()
  local specs

  before_each(function()
    package.loaded["yoda.plugins.util"] = nil
    specs = require("yoda.plugins.util")
  end)

  local function by_name(name)
    for _, spec in ipairs(specs) do
      if spec[1] == name then
        return spec
      end
    end
    return nil
  end

  it("declares vim-repeat, deferred to VeryLazy", function()
    -- Assert
    local spec = by_name("tpope/vim-repeat")
    assert.is_not_nil(spec)
    assert.equals("VeryLazy", spec.event)
  end)

  it("declares vim-sleuth, deferred to BufReadPost", function()
    -- Assert
    local spec = by_name("tpope/vim-sleuth")
    assert.is_not_nil(spec)
    assert.equals("BufReadPost", spec.event)
  end)

  it("declares showkeys with its toggle commands and default opts", function()
    -- Assert
    local spec = by_name("nvzone/showkeys")
    assert.is_not_nil(spec)
    assert.same({ "ShowkeysToggle", "Showkeys" }, spec.cmd)
    assert.equals(1, spec.opts.timeout)
    assert.equals(5, spec.opts.maxkeys)
    assert.equals("top-right", spec.opts.position)
  end)
end)
