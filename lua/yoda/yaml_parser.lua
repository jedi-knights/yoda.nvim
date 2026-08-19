-- Backwards-compat shim (removed alongside init.lua in v1.0.0's atomic feat!:
-- commit). New code should require yoda.core.yaml_parser directly — the
-- parser is fully pure and has no UI counterpart.
return require("yoda.core.yaml_parser")
