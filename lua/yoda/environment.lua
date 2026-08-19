-- Backwards-compat shim (removed alongside init.lua in v1.0.0's atomic feat!:
-- commit). New code should require yoda.core.environment for the pure mode
-- getter and yoda.ui.environment for startup notifications.
return require("yoda.ui.environment")
