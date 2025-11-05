-- tests/property_based.lua
-- Property-based testing framework for Yoda.nvim
-- Inspired by QuickCheck, Hypothesis, and fast-check

local M = {}

-- Random seed management
local seed = os.time()

--- Set random seed for reproducibility
--- @param new_seed number
function M.set_seed(new_seed)
  seed = new_seed
  math.randomseed(seed)
end

-- Initialize with current time
M.set_seed(seed)

--- Get current seed (for reproducing failures)
--- @return number
function M.get_seed()
  return seed
end

-- ============================================================================
-- GENERATORS - Create random test data
-- ============================================================================

local generators = {}

--- Generate random integer in range
--- @param min number Minimum value (inclusive)
--- @param max number Maximum value (inclusive)
--- @return function Generator function
function generators.integer(min, max)
  min = min or 0
  max = max or 100
  assert(type(min) == "number", "min must be a number")
  assert(type(max) == "number", "max must be a number")
  assert(min <= max, "min must be <= max")
  return function()
    return math.random(min, max)
  end
end

--- Generate random boolean
--- @return function Generator function
function generators.boolean()
  return function()
    return math.random() > 0.5
  end
end

--- Generate random string
--- @param min_length number Minimum length
--- @param max_length number Maximum length
--- @param charset string|nil Character set to use
--- @return function Generator function
function generators.string(min_length, max_length, charset)
  min_length = min_length or 0
  max_length = max_length or 20
  charset = charset or "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "

  assert(type(min_length) == "number", "min_length must be a number")
  assert(type(max_length) == "number", "max_length must be a number")
  assert(type(charset) == "string" and #charset > 0, "charset must be a non-empty string")
  assert(min_length >= 0, "min_length must be non-negative")
  assert(min_length <= max_length, "min_length must be <= max_length")

  return function()
    local length = math.random(min_length, max_length)
    local result = {}
    for i = 1, length do
      local pos = math.random(1, #charset)
      result[i] = charset:sub(pos, pos)
    end
    return table.concat(result)
  end
end

--- Generate array of values
--- @param element_gen function Generator for array elements
--- @param min_size number Minimum array size
--- @param max_size number Maximum array size
--- @return function Generator function
function generators.array(element_gen, min_size, max_size)
  min_size = min_size or 0
  max_size = max_size or 10

  assert(type(element_gen) == "function", "element_gen must be a function")
  assert(type(min_size) == "number", "min_size must be a number")
  assert(type(max_size) == "number", "max_size must be a number")
  assert(min_size >= 0, "min_size must be non-negative")
  assert(min_size <= max_size, "min_size must be <= max_size")

  return function()
    local size = math.random(min_size, max_size)
    local result = {}
    for i = 1, size do
      result[i] = element_gen()
    end
    return result
  end
end

--- Generate table with random keys and values
--- @param key_gen function Generator for keys
--- @param value_gen function Generator for values
--- @param min_size number Minimum table size
--- @param max_size number Maximum table size
--- @return function Generator function
function generators.table(key_gen, value_gen, min_size, max_size)
  min_size = min_size or 0
  max_size = max_size or 10

  assert(type(key_gen) == "function", "key_gen must be a function")
  assert(type(value_gen) == "function", "value_gen must be a function")
  assert(type(min_size) == "number", "min_size must be a number")
  assert(type(max_size) == "number", "max_size must be a number")
  assert(min_size >= 0, "min_size must be non-negative")
  assert(min_size <= max_size, "min_size must be <= max_size")

  return function()
    local size = math.random(min_size, max_size)
    local result = {}
    for i = 1, size do
      local key = key_gen()
      local value = value_gen()
      result[key] = value
    end
    return result
  end
end

--- Generate one of several values
--- @param values table Array of possible values
--- @return function Generator function
function generators.one_of(values)
  assert(type(values) == "table" and #values > 0, "one_of requires non-empty array")
  return function()
    return values[math.random(1, #values)]
  end
end

--- Generate tuple of values
--- @param ... function Generators for each tuple element
--- @return function Generator function
function generators.tuple(...)
  local gens = { ... }
  assert(#gens > 0, "tuple requires at least one generator")
  for i, gen in ipairs(gens) do
    assert(type(gen) == "function", "all tuple elements must be generator functions")
  end
  return function()
    local result = {}
    for i, gen in ipairs(gens) do
      result[i] = gen()
    end
    return unpack(result)
  end
end

--- Generate value that satisfies predicate
--- @param gen function Base generator
--- @param predicate function Predicate to satisfy
--- @param max_tries number Maximum attempts
--- @return function Generator function
function generators.such_that(gen, predicate, max_tries)
  max_tries = max_tries or 100
  assert(type(gen) == "function", "gen must be a function")
  assert(type(predicate) == "function", "predicate must be a function")
  assert(type(max_tries) == "number", "max_tries must be a number")
  assert(max_tries > 0, "max_tries must be positive")
  return function()
    for i = 1, max_tries do
      local value = gen()
      if predicate(value) then
        return value
      end
    end
    error("Could not generate value satisfying predicate after " .. max_tries .. " tries")
  end
end

M.gen = generators

-- ============================================================================
-- PROPERTY TESTING
-- ============================================================================

--- Run property-based test
--- @param description string Test description
--- @param options table Options {runs = 100, seed = nil}
--- @param property function Property to test (receives generated values)
function M.property(description, options, property)
  -- Input validation
  assert(type(description) == "string" and description ~= "", "description must be a non-empty string")

  -- Handle optional options parameter
  if type(options) == "function" then
    property = options
    options = {}
  end

  assert(type(property) == "function", "property must be a function")
  assert(type(options) == "table", "options must be a table")

  options = options or {}
  local runs = options.runs or 100
  local test_seed = options.seed or seed

  assert(type(runs) == "number" and runs > 0, "runs must be a positive number")

  -- Save and restore seed for reproducibility
  local original_seed = seed
  M.set_seed(test_seed)

  local failures = {}
  local shrink_attempts = 0

  for run = 1, runs do
    -- Run property test
    local ok, err = pcall(property, run)

    if not ok then
      table.insert(failures, {
        run = run,
        seed = test_seed,
        error = err,
      })
    end
  end

  -- Restore original seed
  M.set_seed(original_seed)

  -- Report results
  if #failures > 0 then
    local msg = string.format("\nProperty '%s' failed %d/%d runs:\n", description, #failures, runs)
    for _, failure in ipairs(failures) do
      msg = msg .. string.format("  Run #%d (seed=%d): %s\n", failure.run, failure.seed, failure.error)
    end
    error(msg)
  end
end

-- ============================================================================
-- PROPERTY ASSERTIONS
-- ============================================================================

local properties = {}

--- Assert property: f(f(x)) = x (involution)
--- @param func function Function to test
--- @param gen function Generator for inputs
--- @param equals function|nil Equality function (default: ==)
--- @param formatter function|nil Formatter for error messages (default: vim.inspect)
function properties.involutory(func, gen, equals, formatter)
  equals = equals or function(a, b)
    return a == b
  end
  formatter = formatter or vim.inspect

  return function()
    local input = gen()
    local output = func(func(input))
    assert(equals(input, output), string.format("Involution failed: f(f(%s)) ≠ %s", formatter(input), formatter(input)))
  end
end

--- Assert property: f(x, y) = f(y, x) (commutativity)
--- @param func function Function to test
--- @param gen function Generator for inputs
--- @param equals function|nil Equality function
--- @param formatter function|nil Formatter for error messages (default: vim.inspect)
function properties.commutative(func, gen, equals, formatter)
  equals = equals or function(a, b)
    return a == b
  end
  formatter = formatter or vim.inspect

  return function()
    local x = gen()
    local y = gen()
    local result1 = func(x, y)
    local result2 = func(y, x)
    assert(
      equals(result1, result2),
      string.format("Commutativity failed: f(%s, %s) ≠ f(%s, %s)", formatter(x), formatter(y), formatter(y), formatter(x))
    )
  end
end

--- Assert property: f(f(x, y), z) = f(x, f(y, z)) (associativity)
--- @param func function Function to test
--- @param gen function Generator for inputs
--- @param equals function|nil Equality function
function properties.associative(func, gen, equals)
  equals = equals or function(a, b)
    return a == b
  end

  return function()
    local x = gen()
    local y = gen()
    local z = gen()
    local result1 = func(func(x, y), z)
    local result2 = func(x, func(y, z))
    assert(equals(result1, result2), string.format("Associativity failed: f(f(x, y), z) ≠ f(x, f(y, z))"))
  end
end

--- Assert property: f(identity, x) = x and f(x, identity) = x
--- @param func function Function to test
--- @param identity any Identity element
--- @param gen function Generator for inputs
--- @param equals function|nil Equality function
function properties.has_identity(func, identity, gen, equals)
  equals = equals or function(a, b)
    return a == b
  end

  return function()
    local x = gen()
    local result1 = func(identity, x)
    local result2 = func(x, identity)
    assert(equals(result1, x) and equals(result2, x), string.format("Identity failed: f(identity, x) or f(x, identity) ≠ x"))
  end
end

--- Assert property: output always satisfies predicate
--- @param func function Function to test
--- @param gen function Generator for inputs
--- @param predicate function Predicate to check
--- @param formatter function|nil Formatter for error messages (default: vim.inspect)
function properties.always_satisfies(func, gen, predicate, formatter)
  formatter = formatter or vim.inspect
  return function()
    local input = gen()
    local output = func(input)
    assert(predicate(output), string.format("Output %s does not satisfy predicate", formatter(output)))
  end
end

M.properties = properties

-- ============================================================================
-- SHRINKING (Advanced: Simplify failing test cases)
-- ============================================================================

--- Shrink a number toward zero
--- @param value number Number to shrink
--- @return table Array of simpler numbers
local function shrink_number(value)
  local shrunk = {}
  if value > 0 then
    table.insert(shrunk, 0)
    table.insert(shrunk, math.floor(value / 2))
  elseif value < 0 then
    table.insert(shrunk, 0)
    table.insert(shrunk, math.ceil(value / 2))
  end
  return shrunk
end

--- Shrink a string to shorter forms
--- @param value string String to shrink
--- @return table Array of simpler strings
local function shrink_string(value)
  local shrunk = {}
  if #value > 0 then
    table.insert(shrunk, "")
    if #value > 1 then
      table.insert(shrunk, value:sub(1, math.floor(#value / 2)))
      table.insert(shrunk, value:sub(2))
      table.insert(shrunk, value:sub(1, -2))
    end
  end
  return shrunk
end

--- Shrink a table to smaller forms
--- @param value table Table to shrink
--- @return table Array of simpler tables
local function shrink_table(value)
  local shrunk = {}
  if #value > 0 then
    table.insert(shrunk, {})
    if #value > 1 then
      local half = {}
      for i = 1, math.floor(#value / 2) do
        half[i] = value[i]
      end
      table.insert(shrunk, half)
    end
  end
  return shrunk
end

--- Shrink a value to simpler form (for better error messages)
--- @param value any Value to shrink
--- @return table Array of simpler values
function M.shrink(value)
  local value_type = type(value)

  if value_type == "number" then
    return shrink_number(value)
  elseif value_type == "string" then
    return shrink_string(value)
  elseif value_type == "table" then
    return shrink_table(value)
  end

  return {}
end

-- ============================================================================
-- STATISTICS & REPORTING
-- ============================================================================

--- Collect statistics about generated values
--- @param description string Statistic description
--- @param gen function Generator
--- @param classifier function Function that classifies values
--- @param runs number Number of runs
function M.classify(description, gen, classifier, runs)
  assert(type(description) == "string", "description must be a string")
  assert(type(gen) == "function", "gen must be a function")
  assert(type(classifier) == "function", "classifier must be a function")
  runs = runs or 100
  assert(type(runs) == "number" and runs > 0, "runs must be a positive number")
  local counts = {}

  for i = 1, runs do
    local value = gen()
    local label = classifier(value)
    counts[label] = (counts[label] or 0) + 1
  end

  print(string.format("\nClassification: %s (%d runs)", description, runs))
  for label, count in pairs(counts) do
    local percentage = (count / runs) * 100
    print(string.format("  %s: %d (%.1f%%)", label, count, percentage))
  end
end

return M
