-- lua/custom/plugins/init.lua
-- All plugin specifications in one place (kickstart-modular style)

return {
  -- ============================================================================
  -- CORE UTILITIES
  -- ============================================================================

  -- Impatient - Faster Lua module loading
  {
    "lewis6991/impatient.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("impatient").enable_profile()
    end,
  },

  -- Plenary - Lua utility library (required by many plugins)
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
    ft = "lua",
    event = { "BufReadPre *.spec.lua", "BufReadPre *_spec.lua" },
  },

  -- ============================================================================
  -- MOTION & NAVIGATION
  -- ============================================================================

  -- Leap - Fast motion between visible targets
  {
    "ggandor/leap.nvim",
    event = "VeryLazy",
    config = function()
      require("leap").add_default_mappings()
    end,
  },

  -- Vim Tmux Navigator - Seamless navigation between vim and tmux
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  -- ============================================================================
  -- UI & COLORS
  -- ============================================================================

  -- Tokyo Night - Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },

  -- Snacks - Modern UI framework
  {
    "folke/snacks.nvim",
    lazy = true,
    cmd = { "SnacksExplorer", "SnacksPicker", "SnacksTerminal" },
    config = function()
      require("snacks").setup()
    end,
  },

  -- Devicons - File type icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    priority = 1000,
    config = function()
      require("nvim-web-devicons").setup({
        default = true,
        strict = false,
      })
    end,
  },

  -- ============================================================================
  -- LSP & COMPLETION
  -- ============================================================================

  -- Mason - LSP, DAP, and linter installer
  {
    "williamboman/mason.nvim",
    lazy = true,
    event = "VeryLazy",
    build = ":MasonUpdate",
    config = function()
      local mason_ok, mason = pcall(require, "mason")
      if mason_ok then
        mason.setup()
      end
    end,
  },

  -- Mason LSP Config - Automatic LSP server installation
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      local mason_lsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
      if mason_lsp_ok then
        mason_lspconfig.setup({
          ensure_installed = {
            "lua_ls",
            "gopls",
            "ts_ls",
          },
        })
      end
    end,
  },

  -- Nvim LSP Config - LSP client configurations
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    event = "VeryLazy",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      require("yoda.lsp")
    end,
  },

  -- ============================================================================
  -- FILE EXPLORER & PICKER
  -- ============================================================================

  -- nvim-tree - File explorer
  {
    "nvim-tree/nvim-tree.lua",
    lazy = true,
    cmd = { "NvimTreeToggle", "NvimTreeOpen" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      })
    end,
  },

  -- Telescope - Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<C-d>"] = false,
            },
          },
        },
      })
    end,
  },

  -- Telescope fzf native
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    lazy = true,
    build = "make",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },

  -- ============================================================================
  -- AI INTEGRATION
  -- ============================================================================

  -- GitHub Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>",
          },
          layout = {
            position = "bottom",
            ratio = 0.4,
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = false,
          debounce = 75,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = "node",
        server_opts_overrides = {},
      })
    end,
  },

  -- Claude Code CLI integration (if available)
  {
    "anthropics/claude-code-cli",
    lazy = true,
    cmd = "claude",
    cond = function()
      return vim.fn.executable("claude") == 1
    end,
  },

  -- ============================================================================
  -- DEVELOPMENT TOOLS
  -- ============================================================================

  -- Trouble - Diagnostics and references
  {
    "folke/trouble.nvim",
    lazy = true,
    cmd = { "Trouble", "TroubleToggle" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup({
        auto_open = false,
        auto_close = false,
        auto_preview = true,
        auto_fold = false,
        auto_jump = { "lsp_definitions" },
        signs = {
          error = "󰅚",
          warning = "󰀪",
          hint = "󰌶",
          information = "󰋼",
          other = "󰗀",
        },
      })
    end,
  },

  -- ============================================================================
  -- GIT INTEGRATION
  -- ============================================================================

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
          ignore_whitespace = false,
        },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = "single",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })

          map("n", "[c", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })

          -- Actions
          map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
          map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
          map("n", "<leader>hS", gs.stage_buffer)
          map("n", "<leader>hu", gs.undo_stage_hunk)
          map("n", "<leader>hR", gs.reset_buffer)
          map("n", "<leader>hp", gs.preview_hunk)
          map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
          end)
          map("n", "<leader>tb", gs.toggle_current_line_blame)
          map("n", "<leader>hd", gs.diffthis)
          map("n", "<leader>hD", function()
            gs.diffthis("~")
          end)
          map("n", "<leader>td", gs.toggle_deleted)

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      })
    end,
  },
}