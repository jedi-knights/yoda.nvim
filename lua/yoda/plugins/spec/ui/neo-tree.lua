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
      name = function(state)
        -- Show only the final directory name as the window title
        return "󰉋  " .. vim.fn.fnamemodify(state.path, ":t")
      end,
      mappings = {
        -- Add custom mappings here if needed
      },
    },
    filesystem = {
      bind_to_cwd = true,               -- respect vim's cwd
      cwd_target = {
        sidebar = "tab",                -- use tab-local cwd
        --current = "window",             -- optional
      },
      -- Set root dir to the current buffer's path (aka your working project dir)
      commands = {
        set_root_to_cwd = function(state)
          local path = vim.fn.getcwd()
          require("neo-tree.sources.manager").set_root("filesystem", path)
        end,
      },
      -- Default: {"icon", "name", "diagnostics", "git_status", "file_size"}
      renderers = {
        file = {
          { "icon" },
          { "name" },
          { "diagnostics" },
          { "git_status" },
          -- { "file_size" },
        },
        directory = {
          { "icon" },
          { "name" },
          { "clipboard" },
          { "diagnostics" },
          { "git_status" },
        },
      },
      hijack_netrw_behavior = "open_default", -- replace netrw
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
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          local cwd = vim.fn.getcwd()
          local root_name = vim.fn.fnamemodify(cwd, ":t") -- tail (last part of path)
          local bufnr = vim.api.nvim_get_current_buf()
          local winid = vim.fn.bufwinid(bufnr)
          if winid ~= -1 then
            vim.wo[winid].winbar = "󰉋  " .. root_name
          end
        end,
      },
    },
  },
}

