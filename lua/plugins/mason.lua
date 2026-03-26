-- lua/plugins/mason.lua

return {
  "williamboman/mason.nvim",
  event = "VeryLazy",
  build = ":MasonUpdate",
  config = function()
    local mason_ok, mason = pcall(require, "mason")
    if mason_ok then
      mason.setup()
    end
  end,
}
