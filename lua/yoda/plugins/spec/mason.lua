return {
  "williamboman/mason.nvim",
  lazy = false,
  -- build = ":MasonUpdate", -- Temporarily removed to avoid async issues
  config = function()
    local mason_ok, mason = pcall(require, "mason")
    if mason_ok then
      mason.setup()
    end
  end,
}

