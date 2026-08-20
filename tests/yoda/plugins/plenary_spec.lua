-- tests/yoda/plugins/plenary_spec.lua

describe("plugins.plenary", function()
  it("declares plenary.nvim, lazy-loaded for lua spec files", function()
    -- Act
    package.loaded["yoda.plugins.plenary"] = nil
    local spec = require("yoda.plugins.plenary")

    -- Assert
    assert.equals("nvim-lua/plenary.nvim", spec[1])
    assert.is_true(spec.lazy)
    assert.equals("lua", spec.ft)
    assert.same(
      { "BufReadPre *.spec.lua", "BufReadPre *_spec.lua" },
      spec.event
    )
  end)
end)
