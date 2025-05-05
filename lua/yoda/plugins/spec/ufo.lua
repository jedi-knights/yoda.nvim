return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    { "kevinhwang91/promise-async" },
  },
  event = "BufReadPost", -- optional: lazy-load on file read
  config = function()
    -- Set up fold settings
    vim.o.foldcolumn = "1" -- shows the fold column
    vim.o.foldlevel = 99   -- ensure folds are open by default
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    -- Set foldmethod and foldexpr to use ufo
    vim.o.foldmethod = "expr"
    vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

    require("ufo").setup({
      provider_selector = function(bufnr, filetype, buftype)
        -- You can customize how folds are provided per filetype/buftype
        return { "treesitter", "indent" }
      end,
    })
  end,
}
