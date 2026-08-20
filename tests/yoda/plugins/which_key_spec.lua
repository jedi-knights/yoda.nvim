-- tests/yoda/plugins/which_key_spec.lua

describe("plugins.which-key", function()
  local spec

  before_each(function()
    package.loaded["yoda.plugins.which-key"] = nil
    spec = require("yoda.plugins.which-key")
  end)

  it("declares which-key.nvim, deferred to VeryLazy", function()
    -- Assert
    assert.equals("folke/which-key.nvim", spec[1])
    assert.equals("VeryLazy", spec.event)
  end)

  it("shows the popup after a short delay using the helix preset", function()
    -- Assert
    assert.equals(200, spec.opts.delay)
    assert.equals("helix", spec.opts.preset)
  end)

  it("groups every leader prefix yoda registers keymaps under", function()
    -- Arrange
    local group_by_prefix = {}
    for _, entry in ipairs(spec.opts.spec) do
      if entry.group then
        group_by_prefix[entry[1]] = entry.group
      end
    end

    -- Assert
    assert.equals("AI", group_by_prefix["<leader>a"])
    assert.equals("Debug", group_by_prefix["<leader>d"])
    assert.equals("Git", group_by_prefix["<leader>g"])
    assert.equals("LSP", group_by_prefix["<leader>l"])
    assert.equals("Toggle/Test", group_by_prefix["<leader>t"])
    assert.equals("JavaScript", group_by_prefix["<leader>j"])
    assert.equals("Python", group_by_prefix["<leader>p"])
    assert.equals("Rust", group_by_prefix["<leader>r"])
  end)
end)
