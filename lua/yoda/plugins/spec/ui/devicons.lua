return {
  "nvim-tree/nvim-web-devicons",
  lazy = false,
  priority = 1000,
  config = function()
    require("nvim-web-devicons").setup({
      -- Enable icons
      default = true,
      -- Enable strict mode (only show icons for supported filetypes)
      strict = false,
      -- Override or add specific icons
      override = {
        zsh = {
          icon = "",
          color = "#428850",
          cterm_color = "65",
          name = "Zsh"
        },
        fish = {
          icon = "",
          color = "#4d5a5e",
          cterm_color = "240",
          name = "Fish"
        },
      },
      -- Override by filename
      override_by_filename = {
        [".gitignore"] = {
          icon = "",
          color = "#f1502f",
          name = "Gitignore"
        },
        ["README.md"] = {
          icon = "",
          color = "#519aba",
          name = "Readme"
        },
        ["Makefile"] = {
          icon = "",
          color = "#427819",
          name = "Makefile"
        },
        ["docs/KEYMAPS.md"] = {
          icon = "🗝️",
          color = "#519aba", 
          name = "Keymaps"
        },
      },
      -- Override by file extension
      override_by_extension = {
        ["log"] = {
          icon = "",
          color = "#81e043",
          name = "Log"
        },
        ["feature"] = {
          icon = "",
          color = "#44a51c",
          name = "Gherkin"
        },
      },
      -- Globally enable default icons (set to true if you don't have a Nerd Font)
      color_icons = true,
    })
  end,
}
