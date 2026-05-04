-- tests/unit/keymaps/terminal_spec.lua
-- Verify terminal keymaps are defined in the source file.

describe("keymaps.terminal", function()
  local filepath = vim.fn.getcwd() .. "/lua/yoda/keymaps/terminal.lua"

  local function read_source()
    local lines = vim.fn.readfile(filepath)
    assert.is_not_nil(lines, "terminal.lua should exist")
    return table.concat(lines, "\n")
  end

  it("maps <C-h> in terminal mode to move to the left window", function()
    local content = read_source()
    assert.is_truthy(content:find('map%("t",%s*"<C%-h>"'), "Expected <C-h> terminal mode mapping for left window navigation")
  end)

  it("maps <C-j> in terminal mode to move to the window below", function()
    local content = read_source()
    assert.is_truthy(content:find('map%("t",%s*"<C%-j>"'), "Expected <C-j> terminal mode mapping for down window navigation")
  end)

  it("maps <C-k> in terminal mode to move to the window above", function()
    local content = read_source()
    assert.is_truthy(content:find('map%("t",%s*"<C%-k>"'), "Expected <C-k> terminal mode mapping for up window navigation")
  end)

  it("maps <C-l> in terminal mode to move to the right window", function()
    local content = read_source()
    assert.is_truthy(content:find('map%("t",%s*"<C%-l>"'), "Expected <C-l> terminal mode mapping for right window navigation")
  end)
end)
