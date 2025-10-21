-- lua/yoda/core/platform_di.lua
-- Platform utilities with Dependency Injection - PERFECT DRY
-- Zero duplication: thin wrapper around standard module using DI factory

local di_factory = require("yoda.di.factory")

-- Perfect DRY: No code duplication, just a wrapper
return di_factory.wrap_standard_module("yoda.core.platform", {
  -- Platform utilities are pure functions with no dependencies
  -- Empty schema = no required dependencies
})
