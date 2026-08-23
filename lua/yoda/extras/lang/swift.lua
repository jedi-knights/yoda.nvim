-- lua/yoda/extras/lang/swift.lua
-- Opt-in Swift stack: sourcekit-lsp (toolchain-provided).
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.swift" }
--
-- sourcekit-lsp ships with the Swift toolchain (Xcode on macOS, `swiftly` or
-- `apt install swift-lang` on Linux) and is intentionally NOT registered with
-- mason-lspconfig: Mason would fetch a 500MB+ toolchain even on macOS where
-- Xcode already provides a working sourcekit-lsp on PATH. Instead the extra
-- calls vim.lsp.enable directly when the binary is present, and emits a
-- one-shot notification pointing at the install docs otherwise.
--
-- No neotest adapter: swift-testing / XCTest are best driven through
-- `swift test` and Xcode's test runner. No DAP wiring: codelldb (already in
-- core mason-nvim-dap) handles Swift binaries the same as C/C++; use the
-- clang extra's launch config or write project-specific launch.json.
if vim.fn.executable("sourcekit-lsp") == 1 then
  vim.lsp.enable("sourcekit")
else
  vim.schedule(function()
    vim.notify(
      "[yoda] swift extra: sourcekit-lsp not found on PATH. "
        .. "Install Xcode (macOS) or `swiftly install latest` (Linux), then "
        .. "reopen a Swift file.",
      vim.log.levels.INFO
    )
  end)
end

return {}
