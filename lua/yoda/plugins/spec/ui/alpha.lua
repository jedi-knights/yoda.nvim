return {
  'goolord/alpha-nvim',
  lazy = false,
  priority = 1000,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },

  config = function()
    require('nvim-web-devicons').setup()

    local alpha = require('alpha')
    local theme = require('yoda.theme')

    -- Define Yoda green highlight groups
    vim.cmd([[highlight AlphaHeader guifg=#7FFF00]])
    vim.cmd([[highlight AlphaButton guifg=#7FFF00]])
    vim.cmd([[highlight AlphaButtonHeader guifg=#7FFF00 gui=bold]])
    vim.cmd([[highlight AlphaFooter guifg=#7FFF00]])

    alpha.setup({
      layout = theme.layout,
      opts = { margin = 5, noautocmd = true },
    })
  end,
}
