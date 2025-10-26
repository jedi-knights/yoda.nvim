-- lua/plugins/languages/rust/neotest_rust.lua
-- Neotest Rust adapter

return {
  "rouge8/neotest-rust",
  lazy = true,
  dependencies = { "nvim-neotest/neotest" },
  ft = "rust",
}
