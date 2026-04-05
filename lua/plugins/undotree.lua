-- lua/plugins/undotree.lua
-- Built-in undotree (Neovim 0.12+), loaded via :packadd

return {
  "nvim.undotree",
  virtual = true,
  keys = {
    {
      "<leader>u",
      function()
        vim.cmd.packadd("nvim.undotree")
        vim.cmd("Undotree")
      end,
      desc = "Toggle undotree",
    },
  },
}
