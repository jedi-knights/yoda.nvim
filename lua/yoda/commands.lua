-- lua/yoda/commands.lua

local M = {}

function M.setup()
  -- delete all @pytest.mark lines
  vim.api.nvim_create_user_command("DeletePytestMarks", function()
    vim.cmd([[g/@pytest\.mark/d]])
  end, {})
end

return M

