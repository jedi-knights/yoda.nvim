-- lua/plugins/dev_tools/overseer.lua
-- Overseer.nvim - Task runner for cargo commands

return {
  "stevearc/overseer.nvim",
  cmd = { "OverseerRun", "OverseerToggle", "OverseerInfo", "OverseerBuild" },
  config = function()
    require("overseer").setup({
      templates = { "builtin" },
      task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
    })
  end,
}
