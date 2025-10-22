-- lua/yoda/core/table_di.lua
-- Table manipulation utilities with Dependency Injection
-- Pure utility module - no dependencies needed, but maintains consistency

local M = {}

--- Create new table utilities instance (DI factory pattern)
--- @param deps table|nil No dependencies needed for pure utilities
--- @return table Table utilities instance
function M.new(deps)
  deps = deps or {}
  local instance = {}

  --- Merge two tables (shallow copy)
  --- @param defaults table
  --- @param overrides table|nil
  --- @return table
  function instance.merge(defaults, overrides)
    if type(defaults) ~= "table" then
      defaults = {}
    end
    if not overrides or type(overrides) ~= "table" then
      return vim.deepcopy(defaults)
    end

    local result = vim.deepcopy(defaults)
    for k, v in pairs(overrides) do
      result[k] = v
    end
    return result
  end

  --- Deep copy a table
  --- @param orig any
  --- @return any
  function instance.deep_copy(orig)
    if type(orig) ~= "table" then
      return orig
    end

    local copy = {}
    for k, v in pairs(orig) do
      if type(v) == "table" then
        copy[k] = instance.deep_copy(v)
      else
        copy[k] = v
      end
    end

    -- Copy metatable if present
    local mt = getmetatable(orig)
    if mt then
      setmetatable(copy, instance.deep_copy(mt))
    end

    return copy
  end

  --- Check if table is empty
  --- @param tbl table
  --- @return boolean
  function instance.is_empty(tbl)
    if type(tbl) ~= "table" then
      return false
    end
    return next(tbl) == nil
  end

  --- Get table size (count all keys)
  --- @param tbl table
  --- @return number
  function instance.size(tbl)
    if type(tbl) ~= "table" then
      return 0
    end

    local count = 0
    for _ in pairs(tbl) do
      count = count + 1
    end
    return count
  end

  --- Check if table contains value
  --- @param tbl table
  --- @param value any
  --- @return boolean
  function instance.contains(tbl, value)
    if type(tbl) ~= "table" then
      return false
    end

    for _, v in pairs(tbl) do
      if v == value then
        return true
      end
    end
    return false
  end

  return instance
end

return M
