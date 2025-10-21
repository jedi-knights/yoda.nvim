-- lua/yoda/adapters/notification_di.lua
-- Notification adapter with Dependency Injection - PERFECT DRY
-- Zero duplication: thin wrapper around standard adapter using DI factory

local di_factory = require("yoda.di.factory")

-- Perfect DRY: No code duplication, just a wrapper
return di_factory.wrap_standard_module("yoda.adapters.notification", {
  -- Notification adapters can work with optional backend preference
  default_backend = {
    required = false,
    type = "string",
  },
})
