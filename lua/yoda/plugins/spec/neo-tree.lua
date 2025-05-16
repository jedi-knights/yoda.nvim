return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  lazy = false,
  ---@module "neo-tree"
  ---@type neotree.Config?
  opts = {
    close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
    window = {
      width = 35,
      auto_expand_width = true,
      mappings = {
      }, -- (leave your custom mappings here later)
    },
    filesystem = {
      filtered_items = {
        visible = false, -- show hidden file
        show_hidden_count = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          "package-lock.json",
          ".changeset",
          ".prettierrc.json",
          ".DS_Store",
          "thumbs.db",
        },
        never_show = { ".git" },
      },
      follow_current_file = {
        enabled = true, -- follow the current buffer
        leave_dirs_open = false, -- optionally collapse dirs unrelated to the file
      },
      use_libuv_file_watcher = true, -- use vim.loop to watch for changes
    },
    buffers = {
      follow_current_file = {
        enabled = true, -- also follow in buffers view
      },
    },
  },
}

