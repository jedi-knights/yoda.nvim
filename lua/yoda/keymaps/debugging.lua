local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })

map("n", "<leader>dc", function()
  require("dap").continue()
end, { desc = "Debug: Continue/Start" })

map("n", "<leader>do", function()
  require("dap").step_over()
end, { desc = "Debug: Step Over" })

map("n", "<leader>di", function()
  require("dap").step_into()
end, { desc = "Debug: Step Into" })

map("n", "<leader>dO", function()
  require("dap").step_out()
end, { desc = "Debug: Step Out" })

map("n", "<leader>dq", function()
  require("dap").terminate()
end, { desc = "Debug: Terminate" })

map("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Debug: Toggle UI" })
