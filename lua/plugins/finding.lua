-- lua/plugins/finding.lua
-- Fuzzy finding and search plugins

return {
  -- fzf-lua - Fast and reliable fuzzy finder (Telescope/Snacks picker crash in Neovim 0.11.x)
  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find Files - Fuzzy find files in current directory" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Find Text - Live grep search across files" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent Files - Browse recently opened files" },
      { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Find Buffers - Switch between open buffers" },
      {
        "<leader>fR",
        "<cmd>FzfLua lsp_document_symbols<CR>",
        desc = "Find Rust/LSP symbols - Search symbols in current document",
      },
      {
        "<leader>fS",
        "<cmd>FzfLua lsp_workspace_symbols<CR>",
        desc = "Find workspace symbols - Search symbols across workspace",
      },
      {
        "<leader>fD",
        "<cmd>FzfLua diagnostics_document<CR>",
        desc = "Find diagnostics - Browse all diagnostics in workspace",
      },
      { "<leader>fG", "<cmd>FzfLua git_files<CR>", desc = "Find Git files - Search files tracked by git" },
    },
    config = function()
      require("fzf-lua").setup({
        winopts = {
          height = 0.85,
          width = 0.80,
          row = 0.35,
          col = 0.50,
          border = "rounded",
          preview = {
            layout = "horizontal",
            horizontal = "right:50%",
          },
        },
        fzf_opts = {
          ["--layout"] = "reverse",
          ["--info"] = "inline",
        },
        files = {
          prompt = "Files> ",
          cmd = "fd --type f --hidden --follow --exclude .git",
        },
        grep = {
          prompt = "Grep> ",
          cmd = "rg --column --line-number --no-heading --color=always --smart-case",
        },
      })
    end,
  },

  -- Telescope - Fuzzy finder (DISABLED: crashes in Neovim 0.11.x)
  {
    "nvim-telescope/telescope.nvim",
    enabled = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    priority = 900,
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
            },
            n = {
              ["<esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["H"] = actions.move_to_top,
              ["M"] = actions.move_to_middle,
              ["L"] = actions.move_to_bottom,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["gg"] = actions.move_to_top,
              ["G"] = actions.move_to_bottom,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
            },
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
            previewer = false,
          },
        },
        extensions = {},
      })
    end,
  },
}
