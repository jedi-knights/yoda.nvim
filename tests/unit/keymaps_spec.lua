-- tests/unit/keymaps_spec.lua
-- Static analysis tests for keymap collision detection.
-- Parses source files directly — no runtime dependencies required.

describe("keymaps", function()
  local keymap_dir = vim.fn.stdpath("config") .. "/lua/yoda/keymaps"

  -- Keys intentionally mapped in multiple files (e.g. <nop> to disable keys)
  local ALLOWED_CROSS_FILE_DUPLICATES = {
    ["<nop>"] = true,
  }

  --- Extract {mode, key} pairs from a Lua source file by matching map() and
  --- vim.keymap.set() call sites. This is intentionally simple pattern matching —
  --- it doesn't evaluate the Lua, so it catches literal string arguments only.
  local function extract_keys(filepath)
    local lines = vim.fn.readfile(filepath)
    if not lines then
      return {}
    end
    local content = table.concat(lines, "\n")
    local keys = {}

    -- map("n", "<key>", ...) or map('n', '<key>', ...)
    for mode, key in content:gmatch("map%s*%([\"'](%a+)[\"']%s*,%s*[\"']([^\"']+)[\"']") do
      table.insert(keys, { mode = mode, key = key })
    end

    -- vim.keymap.set("n", "<key>", ...) or vim.keymap.set('n', '<key>', ...)
    for mode, key in content:gmatch("vim%.keymap%.set%s*%([\"'](%a+)[\"']%s*,%s*[\"']([^\"']+)[\"']") do
      table.insert(keys, { mode = mode, key = key })
    end

    return keys
  end

  it("has no within-file duplicate keymaps", function()
    local files = vim.fn.glob(keymap_dir .. "/*.lua", false, true)
    assert.is_true(#files > 0, "Expected keymap files to exist in " .. keymap_dir)

    local violations = {}

    for _, filepath in ipairs(files) do
      local keys = extract_keys(filepath)
      local seen = {}
      local filename = vim.fn.fnamemodify(filepath, ":t")

      for _, entry in ipairs(keys) do
        local combo = entry.mode .. ":" .. entry.key
        if seen[combo] then
          table.insert(violations, string.format("%s: '%s' (mode '%s') defined more than once", filename, entry.key, entry.mode))
        else
          seen[combo] = true
        end
      end
    end

    assert.equals(0, #violations, "Within-file keymap collisions found:\n  " .. table.concat(violations, "\n  "))
  end)

  it("has no cross-file duplicate keymaps (excluding intentional ones)", function()
    local files = vim.fn.glob(keymap_dir .. "/*.lua", false, true)
    assert.is_true(#files > 0, "Expected keymap files to exist in " .. keymap_dir)

    local seen = {} -- combo -> filename
    local violations = {}

    for _, filepath in ipairs(files) do
      local keys = extract_keys(filepath)
      local filename = vim.fn.fnamemodify(filepath, ":t")

      for _, entry in ipairs(keys) do
        if not ALLOWED_CROSS_FILE_DUPLICATES[entry.key] then
          local combo = entry.mode .. ":" .. entry.key
          if seen[combo] then
            table.insert(violations, string.format("'%s' (mode '%s') in both %s and %s", entry.key, entry.mode, seen[combo], filename))
          else
            seen[combo] = filename
          end
        end
      end
    end

    assert.equals(0, #violations, "Cross-file keymap collisions found:\n  " .. table.concat(violations, "\n  "))
  end)

  it("finds keymap files for all modules listed in init.lua", function()
    local init_path = keymap_dir .. "/init.lua"
    local lines = vim.fn.readfile(init_path)
    assert.is_not_nil(lines, "keymaps/init.lua should exist")

    local content = table.concat(lines, "\n")
    local missing = {}

    for module in content:gmatch('require%("yoda%.keymaps%.([^"]+)"%)') do
      local filepath = keymap_dir .. "/" .. module .. ".lua"
      if vim.fn.filereadable(filepath) == 0 then
        table.insert(missing, module .. ".lua")
      end
    end

    assert.equals(0, #missing, "Keymap modules listed in init.lua but missing on disk:\n  " .. table.concat(missing, "\n  "))
  end)
end)
