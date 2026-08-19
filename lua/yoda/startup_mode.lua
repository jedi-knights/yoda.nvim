-- Backwards-compat shim (removed alongside init.lua in v1.0.0's atomic feat!:
-- commit). New code should require yoda.core.startup_mode for the pure
-- argv classifier and yoda.ui.startup_mode for autocmd + layout wiring.
return require("yoda.ui.startup_mode")
