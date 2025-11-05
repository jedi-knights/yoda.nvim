local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint - Set/remove breakpoint at current line" })

map("n", "<leader>dc", function()
  require("dap").continue()
end, { desc = "Debug: Continue/Start - Start debugging or continue to next breakpoint" })

map("n", "<leader>do", function()
  require("dap").step_over()
end, { desc = "Debug: Step Over - Execute current line without entering functions" })

map("n", "<leader>di", function()
  require("dap").step_into()
end, { desc = "Debug: Step Into - Step into function at current line" })

map("n", "<leader>dO", function()
  require("dap").step_out()
end, { desc = "Debug: Step Out - Step out of current function" })

map("n", "<leader>dq", function()
  require("dap").terminate()
end, { desc = "Debug: Terminate - Stop debugging session" })

map("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Debug: Toggle UI - Show/hide debug UI panels" })
