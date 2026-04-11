-- tests/unit/plugins/mini_pick_spec.lua
-- Validates mini.pick and mini.extra plugin specs are correctly defined.

describe("mini.pick plugin spec", function()
  local specs

  before_each(function()
    specs = dofile(vim.fn.getcwd() .. "/lua/plugins/mini.lua")
  end)

  --- Find a spec entry by its plugin name (first element).
  local function find_spec(name)
    for _, spec in ipairs(specs) do
      if spec[1] == name then
        return spec
      end
    end
    return nil
  end

  it("includes mini.pick", function()
    local pick = find_spec("echasnovski/mini.pick")
    assert.is_not_nil(pick, "mini.pick spec not found in mini.lua")
  end)

  it("includes mini.extra", function()
    local extra = find_spec("echasnovski/mini.extra")
    assert.is_not_nil(extra, "mini.extra spec not found in mini.lua")
  end)

  it("mini.pick has event or keys for lazy loading", function()
    local pick = find_spec("echasnovski/mini.pick")
    assert.is_not_nil(pick, "mini.pick spec not found")
    local has_lazy_trigger = pick.event ~= nil or pick.keys ~= nil or pick.cmd ~= nil
    assert.is_true(has_lazy_trigger, "mini.pick should have a lazy-loading trigger (event, keys, or cmd)")
  end)

  it("mini.pick depends on mini.extra", function()
    local pick = find_spec("echasnovski/mini.pick")
    assert.is_not_nil(pick, "mini.pick spec not found")
    assert.is_not_nil(pick.dependencies, "mini.pick should declare dependencies")
    local has_extra = false
    for _, dep in ipairs(pick.dependencies) do
      local dep_name = type(dep) == "string" and dep or dep[1]
      if dep_name == "echasnovski/mini.extra" then
        has_extra = true
        break
      end
    end
    assert.is_true(has_extra, "mini.pick should depend on mini.extra")
  end)

  describe("keymaps", function()
    local expected_keys = {
      { key = "<leader><leader>", desc_pattern = "[Ff]ind [Ff]iles" },
      { key = "<leader>/", desc_pattern = "[Ll]ive [Gg]rep" },
      { key = "<leader>sh", desc_pattern = "[Hh]elp" },
      { key = "<leader>sk", desc_pattern = "[Kk]eymap" },
      { key = "<leader>s.", desc_pattern = "[Rr]ecent" },
      { key = "<leader>sd", desc_pattern = "[Dd]iagnostic" },
      { key = "<leader>sb", desc_pattern = "[Bb]uffer" },
    }

    it("defines all expected keymaps", function()
      local pick = find_spec("echasnovski/mini.pick")
      assert.is_not_nil(pick, "mini.pick spec not found")
      assert.is_not_nil(pick.keys, "mini.pick should have keys defined")

      for _, expected in ipairs(expected_keys) do
        local found = false
        for _, keydef in ipairs(pick.keys) do
          local k = type(keydef) == "table" and keydef[1] or keydef
          if k == expected.key then
            found = true
            break
          end
        end
        assert.is_true(found, "Expected keymap '" .. expected.key .. "' not found in mini.pick keys")
      end
    end)
  end)
end)
