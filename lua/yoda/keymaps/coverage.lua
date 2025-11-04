local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>cv", function()
  require("coverage").load()
  require("coverage").show()
end, { desc = "Coverage: Show" })

map("n", "<leader>cx", function()
  require("coverage").hide()
end, { desc = "Coverage: Hide" })
