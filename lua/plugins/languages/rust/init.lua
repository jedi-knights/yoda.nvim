-- lua/plugins/languages/rust/init.lua
-- Rust language support meta-loader

return {
  { import = "plugins.languages.rust.rust_tools" },
  { import = "plugins.languages.rust.crates" },
  { import = "plugins.languages.rust.neotest_rust" },
}
