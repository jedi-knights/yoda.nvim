local map = vim.keymap.set

map("n", "<leader>cc", function()
  require("coverage").load(true)
end, { desc = "Coverage: Load and display" })

map("n", "<leader>ct", function()
  require("coverage").toggle()
end, { desc = "Coverage: Toggle display" })

map("n", "<leader>cs", function()
  require("coverage").summary()
end, { desc = "Coverage: Show summary" })

return {}
