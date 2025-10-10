-- lua/yoda/core/table.lua
-- Table manipulation utilities (extracted from utils.lua for better organization)

local M = {}

-- ============================================================================
-- TABLE OPERATIONS
-- ============================================================================

--- Merge tables (shallow merge)
--- @param defaults table Default values
--- @param overrides table|nil Override values
--- @return table Merged table
function M.merge(defaults, overrides)
  if type(defaults) ~= "table" then
    defaults = {}
  end

  local result = {}
  for k, v in pairs(defaults) do
    result[k] = v
  end
  for k, v in pairs(overrides or {}) do
    result[k] = v
  end
  return result
end

--- Deep copy a table (recursive)
--- @param orig table Original table
--- @return table Copied table
function M.deep_copy(orig)
  if type(orig) ~= "table" then
    return orig
  end

  local copy = {}
  for key, value in next, orig, nil do
    copy[M.deep_copy(key)] = M.deep_copy(value)
  end
  setmetatable(copy, M.deep_copy(getmetatable(orig)))

  return copy
end

--- Check if table is empty
--- @param tbl table Table to check
--- @return boolean
function M.is_empty(tbl)
  if type(tbl) ~= "table" then
    return true
  end
  return next(tbl) == nil
end

--- Get table size (works for non-sequential tables)
--- @param tbl table Table to measure
--- @return number Count of elements
function M.size(tbl)
  if type(tbl) ~= "table" then
    return 0
  end

  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

--- Check if value exists in table
--- @param tbl table Table to search
--- @param value any Value to find
--- @return boolean
function M.contains(tbl, value)
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

return M
