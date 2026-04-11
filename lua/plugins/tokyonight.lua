-- lua/plugins/tokyonight.lua

return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    -- Deferred via vim.schedule so the colorscheme applies after all lazy = false
    -- plugins have loaded and registered their highlight groups. Applying it
    -- synchronously here (priority 1000) would run before ui2, snacks, and
    -- other plugins that add or override highlights — their ColorScheme handlers
    -- would then re-fire and overwrite ours. Scheduling moves the application to
    -- after lazy.setup() completes, ensuring a single settled highlight state.
    vim.schedule(function()
      local ok = pcall(vim.cmd, "colorscheme tokyonight")
      if not ok then
        vim.notify("Colorscheme 'tokyonight' not found!", vim.log.levels.ERROR)
      end
    end)
  end,
}
