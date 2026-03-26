-- lua/plugins/mini-comment.lua
-- Treesitter-aware commenting via gc/gcc. Neovim 0.10+ has native gc, but it
-- uses &commentstring which breaks in embedded-language contexts (JSX, template
-- strings, mixed HTML/JS). mini.comment detects the correct comment syntax from
-- the treesitter node under the cursor, so gc works correctly regardless of nesting.

return {
  "echasnovski/mini.comment",
  event = "VeryLazy",
  opts = {},
}
