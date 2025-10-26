-- lua/plugins/core/treesitter.lua
-- Treesitter - Syntax highlighting

return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "query",
        "python",
        "go",
        "javascript",
        "typescript",
        "rust",
        "toml",
        "make",
      },
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        disable = function(lang, buf)
          if lang == "make" and vim.api.nvim_buf_line_count(buf) > 4000 then
            return true
          end
          return false
        end,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      markdown = {
        enable = true,
        disable = { "markdown_inline" },
      },
      incremental_selection = { enable = false },
      textobjects = { enable = false },
      refactor = { enable = false },
      autotag = { enable = false },
      context_commentstring = { enable = false },
    })
  end,
}
