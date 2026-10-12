-- lua/yoda/plugins/asmview.lua

-- asmview.nvim — compile the function at the cursor to assembly in a
-- floating window. Supports C, C++, Rust, and Go via each toolchain's
-- native `-S` / `--emit=asm` / `go build -gcflags=-S` path.
--
-- Lazy loads on filetype or on `:Asm` so users with their own
-- `<leader>?` → `<Plug>(AsmView)` mapping get the plugin wired up as
-- soon as they open a supported source file. `<leader>a` is deliberately
-- NOT claimed here — it's the AI group in yoda (lua/yoda/plugins/ai.lua).

return {
  "jedi-knights/asmview.nvim",
  tag = "v0.2.0",
  ft = { "c", "cpp", "cxx", "objcpp", "rust", "go" },
  cmd = "Asm",
  opts = {},
}
