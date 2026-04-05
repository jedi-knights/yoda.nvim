-- lua/plugins/difftool.lua
-- Built-in difftool (Neovim 0.12+), loaded via :packadd

return {
  "nvim.difftool",
  virtual = true,
  cmd = "DiffTool",
  init = function()
    vim.api.nvim_create_user_command("DiffTool", function(opts)
      vim.cmd.packadd("nvim.difftool")
      vim.cmd("DiffTool " .. opts.args)
    end, {
      nargs = "+",
      complete = "file",
      desc = "Compare files or directories (built-in)",
    })
  end,
}
