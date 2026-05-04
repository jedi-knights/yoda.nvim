-- tests/unit/keymaps/window_spec.lua
-- Verify window navigation keymaps are defined in the source file.

describe("keymaps.window", function()
  local filepath = vim.fn.getcwd() .. "/lua/yoda/keymaps/window.lua"

  local function read_source()
    local lines = vim.fn.readfile(filepath)
    assert.is_not_nil(lines, "window.lua should exist")
    return table.concat(lines, "\n")
  end

  it("maps <C-h> to move to the left window", function()
    local content = read_source()
    assert.is_truthy(content:find("<C%-h>"), "Expected <C-h> mapping for left window navigation")
  end)

  it("maps <C-j> to move to the window below", function()
    local content = read_source()
    assert.is_truthy(content:find("<C%-j>"), "Expected <C-j> mapping for down window navigation")
  end)

  it("maps <C-k> to move to the window above", function()
    local content = read_source()
    assert.is_truthy(content:find("<C%-k>"), "Expected <C-k> mapping for up window navigation")
  end)

  it("maps <C-l> to move to the right window", function()
    local content = read_source()
    assert.is_truthy(content:find("<C%-l>"), "Expected <C-l> mapping for right window navigation")
  end)
end)
