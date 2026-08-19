-- Backwards-compat shim (removed alongside init.lua in v1.0.0's atomic feat!:
-- commit). New code should require yoda.core.large_file for pure helpers and
-- yoda.ui.large_file for buffer/autocmd/command wiring.
return require("yoda.ui.large_file")
