-- lua/yoda/commands/tutorial.lua

local M = {}

function M.setup()
  vim.api.nvim_create_user_command("Tutor", function(opts)
    if opts.args and opts.args ~= "" then
      vim.cmd("Tutor " .. opts.args)
    else
      vim.cmd("Tutor")
    end
  end, {
    desc = "Open Neovim tutor",
    nargs = "?",
    complete = "help",
  })
end

return M
