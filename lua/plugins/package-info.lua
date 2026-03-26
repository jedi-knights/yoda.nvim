-- lua/plugins/package-info.lua
-- Show package versions in package.json

return {
  "vuki656/package-info.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  event = { "BufRead package.json" },
  config = function()
    require("package-info").setup({
      highlights = {
        up_to_date = { fg = "#3C4048" },
        outdated = { fg = "#d19a66" },
      },
      icons = {
        enable = true,
        style = {
          up_to_date = "|  ",
          outdated = "|  ",
        },
      },
      autostart = false, -- Don't auto-fetch on file open (prevents spam)
      hide_up_to_date = false,
      hide_unstable_versions = false,
      package_manager = "npm",
    })

    -- Package.json specific keymaps (set in autocmd)
    vim.api.nvim_create_autocmd("BufRead", {
      pattern = "package.json",
      callback = function(args)
        -- Only setup once per buffer
        if vim.b[args.buf].package_info_setup then
          return
        end
        vim.b[args.buf].package_info_setup = true

        local pkg = require("package-info")
        vim.keymap.set("n", "<leader>jf", pkg.show, { desc = "JS: Fetch & show package versions", buffer = true, silent = true })
        vim.keymap.set("n", "<leader>js", pkg.show, { desc = "JS: Show package info", buffer = true, silent = true })
        vim.keymap.set("n", "<leader>ju", pkg.update, { desc = "JS: Update package", buffer = true, silent = true })
        vim.keymap.set("n", "<leader>jd", pkg.delete, { desc = "JS: Delete package", buffer = true, silent = true })
        vim.keymap.set("n", "<leader>ji", pkg.install, { desc = "JS: Install package", buffer = true, silent = true })
        vim.keymap.set("n", "<leader>jv", pkg.change_version, { desc = "JS: Change version", buffer = true, silent = true })

        vim.notify("Package.json opened. Use <leader>jf to fetch versions", vim.log.levels.INFO)
      end,
    })
  end,
}
