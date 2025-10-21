-- lua/yoda/adapters/picker_di.lua
-- Picker adapter with Dependency Injection - PERFECT DRY
-- Zero duplication: thin wrapper around standard adapter using DI factory

local di_factory = require("yoda.di.factory")

-- Perfect DRY: No code duplication, just a wrapper
return di_factory.wrap_standard_module("yoda.adapters.picker", {
  -- Picker adapters can work with optional backend preference
  default_backend = {
    required = false,
    type = "string",
  },
})
