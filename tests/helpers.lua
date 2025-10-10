-- Test helpers and utilities
local M = {}

--- Create a spy function that tracks calls
---@return function spy_fn The spy function
---@return table spy_data The spy metadata
function M.spy()
  local spy_data = {
    called = false,
    call_count = 0,
    calls = {}, -- Array of all call arguments
    last_call = nil,
  }

  local spy_fn = function(...)
    spy_data.called = true
    spy_data.call_count = spy_data.call_count + 1
    spy_data.last_call = { ... }
    table.insert(spy_data.calls, { ... })
    return ...
  end

  return spy_fn, spy_data
end

--- Mock a method on an object
---@param obj table The object to mock
---@param method string The method name
---@param implementation function The mock implementation
---@return function restore Function to restore original
function M.mock(obj, method, implementation)
  local original = obj[method]
  obj[method] = implementation

  return function()
    obj[method] = original
  end
end

--- Mock vim.loop.fs_stat for file system tests
---@param files table Map of paths to stat results
---@return function restore Function to restore original
function M.mock_fs_stat(files)
  local original = vim.loop.fs_stat

  vim.loop.fs_stat = function(path)
    return files[path]
  end

  return function()
    vim.loop.fs_stat = original
  end
end

--- Mock vim.fn.json_decode/json_encode
---@return function restore Function to restore original
function M.mock_json()
  local original_decode = vim.fn.json_decode
  local original_encode = vim.fn.json_encode

  -- Simple mock implementations
  vim.fn.json_decode = function(str)
    -- Very basic JSON parsing for testing
    if str == "null" then
      return nil
    end
    if str == "true" then
      return true
    end
    if str == "false" then
      return false
    end
    if tonumber(str) then
      return tonumber(str)
    end
    return str
  end

  vim.fn.json_encode = function(obj)
    if obj == nil then
      return "null"
    end
    if type(obj) == "boolean" then
      return tostring(obj)
    end
    if type(obj) == "number" then
      return tostring(obj)
    end
    return vim.inspect(obj)
  end

  return function()
    vim.fn.json_decode = original_decode
    vim.fn.json_encode = original_encode
  end
end

--- Create mock Neovim API
---@return table mock_api Mock API functions
function M.mock_nvim_api()
  return {
    nvim_list_wins = function()
      return { 1, 2, 3 }
    end,
    nvim_win_get_buf = function(win)
      return win
    end,
    nvim_buf_get_option = function(buf, opt)
      return ""
    end,
    nvim_buf_get_name = function(buf)
      return "mock_buffer_" .. buf
    end,
    nvim_set_current_win = function(win)
      -- No-op in tests
    end,
    nvim_win_is_valid = function(win)
      return true
    end,
  }
end

--- Assert a spy was called
---@param spy_data table The spy metadata
---@param expected_count? number Expected call count (optional)
function M.assert_called(spy_data, expected_count)
  assert(spy_data.called, "Expected function to be called")
  if expected_count then
    assert.equals(
      expected_count,
      spy_data.call_count,
      string.format("Expected %d calls, got %d", expected_count, spy_data.call_count)
    )
  end
end

--- Assert a spy was called with specific arguments
---@param spy_data table The spy metadata
---@param ... any Expected arguments
function M.assert_called_with(spy_data, ...)
  local expected = { ... }
  M.assert_called(spy_data)
  assert.same(expected, spy_data.last_call, "Function called with unexpected arguments")
end

--- Assert a spy was NOT called
---@param spy_data table The spy metadata
function M.assert_not_called(spy_data)
  assert.is_false(spy_data.called, "Expected function NOT to be called")
end

--- Create a temporary file for testing
---@param content string File content
---@return string path Path to temp file
function M.create_temp_file(content)
  local tmpname = os.tmpname()
  local file = io.open(tmpname, "w")
  if file then
    file:write(content)
    file:close()
  end
  return tmpname
end

--- Clean up a temporary file
---@param path string Path to file
function M.cleanup_temp_file(path)
  os.remove(path)
end

return M

