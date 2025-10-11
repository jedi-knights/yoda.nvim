-- lua/yoda/diagnostics/composite.lua
-- Composite pattern for diagnostics
-- Allows uniform treatment of individual and grouped diagnostics

local M = {}

--- Create new diagnostic composite
--- @return table Composite instance
function M:new()
  local instance = {
    diagnostics = {},
    name = "Composite Diagnostic",
  }
  setmetatable(instance, { __index = M })
  return instance
end

--- Add a diagnostic to the composite
--- @param diagnostic table Diagnostic with check_status() method
--- @return table Self for chaining
function M:add(diagnostic)
  assert(type(diagnostic) == "table", "Diagnostic must be a table")
  assert(type(diagnostic.check_status) == "function", "Diagnostic must have check_status() method")

  table.insert(self.diagnostics, diagnostic)
  return self
end

--- Run all diagnostics and collect results
--- @param opts table|nil Options {silent = boolean, stop_on_failure = boolean}
--- @return table Results {name -> boolean}
function M:run_all(opts)
  opts = opts or {}
  local results = {}

  for _, diagnostic in ipairs(self.diagnostics) do
    local name = diagnostic.get_name and diagnostic:get_name() or "unknown"
    local ok = diagnostic:check_status()
    results[name] = ok

    if opts.stop_on_failure and not ok then
      break
    end
  end

  return results
end

--- Run only critical diagnostics
--- @return table Results {name -> boolean}
function M:run_critical()
  local results = {}

  for _, diagnostic in ipairs(self.diagnostics) do
    if diagnostic.critical then
      local name = diagnostic.get_name and diagnostic:get_name() or "unknown"
      results[name] = diagnostic:check_status()
    end
  end

  return results
end

--- Get count of diagnostics
--- @return number Count
function M:count()
  return #self.diagnostics
end

--- Check if all diagnostics pass
--- @return boolean True if all pass
function M:all_pass()
  for _, diagnostic in ipairs(self.diagnostics) do
    if not diagnostic:check_status() then
      return false
    end
  end
  return true
end

--- Get aggregate status
--- @return table {total, passed, failed, pass_rate}
function M:get_aggregate_status()
  local total = 0
  local passed = 0

  for _, diagnostic in ipairs(self.diagnostics) do
    total = total + 1
    if diagnostic:check_status() then
      passed = passed + 1
    end
  end

  return {
    total = total,
    passed = passed,
    failed = total - passed,
    pass_rate = total > 0 and (passed / total) or 0,
  }
end

--- Diagnostic can also act as a single diagnostic (Composite pattern)
--- @return boolean True if all sub-diagnostics pass
function M:check_status()
  return self:all_pass()
end

--- Get name of this composite
--- @return string Name
function M:get_name()
  return self.name
end

return M

