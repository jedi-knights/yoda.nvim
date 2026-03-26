-- lua/plugins/mini-ai.lua
-- Extended text objects using treesitter. n_lines=50 looks up to 50 lines
-- away for object boundaries, handling long functions without missing closing braces.

return {
  "echasnovski/mini.ai",
  event = "VeryLazy",
  opts = { n_lines = 50 },
}
