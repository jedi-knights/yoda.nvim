-- lua/yoda/core/io_di.lua
-- I/O utilities with Dependency Injection - PERFECT DRY
-- Zero duplication: thin wrapper around compatibility layer

local di_factory = require("yoda.di.factory")

-- Perfect DRY: No code duplication, just a wrapper around compatibility layer
return di_factory.wrap_standard_module("yoda.compat.io", {
  -- I/O operations use compatibility layer (already delegates to focused modules)
  -- No additional dependencies needed
})
