-- lua/yoda/core/table_di.lua
-- Table utilities with Dependency Injection - PERFECT DRY
-- Zero duplication: thin wrapper around standard module using DI factory

local di_factory = require("yoda.di.factory")

-- Perfect DRY: No code duplication, just a wrapper
return di_factory.wrap_standard_module("yoda.core.table", {
  -- Table utilities are pure functions with no dependencies
  -- Empty schema = no required dependencies
})
