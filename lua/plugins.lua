-- lua/plugins.lua
-- All plugin specifications in one place

return {
  -- ============================================================================
  -- CORE UTILITIES
  -- ============================================================================
  -- Note: impatient.nvim removed - vim.loader.enable() in init.lua provides
  -- the same functionality with better integration (Neovim 0.9+)

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
    lazy = false,
    priority = 1000,
    config = function()
      require("snacks").setup({
        explorer = {
          enabled = true,
          show_hidden = true, -- Show hidden files and folders by default
        },
        picker = {
          enabled = true,
        },
        terminal = {
          enabled = true,
        },
      })
    end,
  },

  -- Bufferline - Visual buffer tabs
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          themable = true,
          numbers = "none",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          middle_mouse_command = nil,
          indicator = {
            icon = "▎",
            style = "icon",
          },
          buffer_close_icon = "󰅖",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          offsets = {
            {
              filetype = "snacks-explorer",
              text = "File Explorer",
              text_align = "center",
              separator = true,
            },
          },
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          separator_style = "thin",
          always_show_bufferline = true,
        },
      })
    end,
  },

  -- Alpha - Dashboard
  {
    "goolord/alpha-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Set header
      dashboard.section.header.val = {
        "                                                     ",
        "        ██╗   ██╗ ██████╗ ██████╗  █████╗            ",
        "        ╚██╗ ██╔╝██╔═══██╗██╔══██╗██╔══██╗           ",
        "         ╚████╔╝ ██║   ██║██║  ██║███████║           ",
        "          ╚██╔╝  ██║   ██║██║  ██║██╔══██║           ",
        "           ██║   ╚██████╔╝██████╔╝██║  ██║           ",
        "           ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═╝           ",
        "                                                     ",
        "                                                     ",
      }

      -- Set menu
      dashboard.section.buttons.val = {
        dashboard.button("e", "📁  Open Explorer", "<leader>eo"),
        dashboard.button("f", "🔍  Find Files", "<leader>ff"),
        dashboard.button("g", "🔎  Find Text", "<leader>fg"),
        dashboard.button("r", "📋  Recent Files", ":Telescope oldfiles<CR>"),
        dashboard.button("l", "🔧  Lazy", ":Lazy<CR>"),
        dashboard.button("q", "❌  Quit", ":qa<CR>"),
      }

      -- Set footer
      dashboard.section.footer.val = "May the force be with you"

      -- Configure alpha options
      local alpha_config = {
        redraw_on_resize = true,
        layout = {
          { type = "padding", val = 10 },
          dashboard.section.header,
          { type = "padding", val = 2 },
          dashboard.section.buttons,
          { type = "padding", val = 1 },
          dashboard.section.footer,
          { type = "padding", val = 2 },
        },
        opts = {
          margin = 5,
          setup = function()
            vim.api.nvim_set_option_value("laststatus", 0, { scope = "local" })
            -- Don't hide tabline on dashboard - we want bufferline visible
            -- vim.api.nvim_set_option_value("showtabline", 0, { scope = "local" })
            vim.api.nvim_set_option_value("ruler", false, { scope = "local" })
            vim.api.nvim_set_option_value("showcmd", false, { scope = "local" })
            vim.api.nvim_set_option_value("cmdheight", 0, { scope = "local" })
            vim.api.nvim_set_option_value("number", false, { scope = "local" })
            vim.api.nvim_set_option_value("relativenumber", false, { scope = "local" })
          end,
        },
      }

      -- Send config to alpha
      alpha.setup(alpha_config)
    end,
  },

  -- Noice - Enhanced UI components
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
      })
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
            accept = false, -- Disable built-in, we use custom keymaps
            accept_word = false,
            accept_line = false,
            next = false, -- Disable built-in, we use custom keymaps
            prev = false, -- Disable built-in, we use custom keymaps
            dismiss = false, -- Disable built-in, we use custom keymaps
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

          -- Refresh git signs after git operations
          vim.api.nvim_create_autocmd("User", {
            pattern = "NeogitStatusRefreshed",
            callback = function()
              gs.refresh()
            end,
          })

          vim.api.nvim_create_autocmd("User", {
            pattern = "NeogitCommitComplete",
            callback = function()
              gs.refresh()
            end,
          })

          vim.api.nvim_create_autocmd("User", {
            pattern = "NeogitPushComplete",
            callback = function()
              gs.refresh()
            end,
          })

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

  -- Diffview - Git diff viewer
  {
    "sindrets/diffview.nvim",
    lazy = true,
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewRefresh" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("diffview").setup({
        view = {
          default = {
            layout = "diff2_horizontal",
          },
          merge_tool = {
            layout = "diff3_horizontal",
          },
        },
      })
    end,
  },

  -- ============================================================================
  -- TESTING & DEBUGGING
  -- ============================================================================

  -- Neogit - Git interface
  {
    "TimUntersberger/neogit",
    lazy = true,
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "sindrets/diffview.nvim", -- Required for neogit diff integration
    },
    config = function()
      require("neogit").setup({
        disable_signs = false,
        disable_context_highlighting = false,
        disable_commit_confirmation = false,
        auto_refresh = true,
        sort_branches = "-committerdate",
        disable_builtin_notifications = false,
        use_magit_keybindings = false,
        commit_popup = {
          kind = "split",
        },
        popup = {
          kind = "split",
        },
        signs = {
          hunk = { "", "" },
          item = { ">", "v" },
          section = { ">", "v" },
        },
        integrations = {
          diffview = true,
        },
        sections = {
          untracked = {
            folded = false,
            hidden = false,
          },
          unstaged = {
            folded = false,
            hidden = false,
          },
          staged = {
            folded = false,
            hidden = false,
          },
          stashes = {
            folded = true,
            hidden = false,
          },
          unpulled = {
            folded = true,
            hidden = false,
          },
          unmerged = {
            folded = false,
            hidden = false,
          },
          recent = {
            folded = true,
            hidden = false,
          },
        },
        -- Use default mappings to avoid configuration errors
        -- Custom mappings can be added later once we know the correct command names
      })
    end,
  },

  -- Neotest - Testing framework
  {
    "nvim-neotest/neotest",
    lazy = true,
    cmd = { "Neotest", "NeotestRun", "NeotestSummary", "NeotestOutput" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
          }),
        },
      })
    end,
  },

  -- Neotest Python adapter
  {
    "nvim-neotest/neotest-python",
    lazy = true,
    dependencies = { "nvim-neotest/neotest" },
  },

  -- DAP - Debug Adapter Protocol
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    cmd = { "DapToggleBreakpoint", "DapContinue", "DapStepOver", "DapStepInto", "DapStepOut", "DapTerminate" },
    dependencies = {
      "rcarriga/nvim-dap-ui",
    },
  },

  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()
    end,
  },

  -- Coverage - Code coverage
  {
    "andythigpen/nvim-coverage",
    lazy = true,
    cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageHide" },
    config = function()
      require("coverage").setup()
    end,
  },

  -- ============================================================================
  -- AI INTEGRATION (ADDITIONAL)
  -- ============================================================================

  -- OpenCode - AI assistant integration
  {
    "NickvanDyke/opencode.nvim",
    lazy = true,
    cmd = { "OpencodePrompt", "OpencodeAsk", "OpencodeSelect", "OpencodeToggle" },
    dependencies = {
      "folke/snacks.nvim", -- Required for toggle functionality
    },
    config = function()
      vim.g.opencode_opts = {
        -- Auto-reload buffers edited by opencode
        auto_reload = true,
      }

      -- Required for auto_reload
      vim.opt.autoread = true
    end,
  },

  -- ============================================================================
  -- UTILITIES
  -- ============================================================================

  -- Treesitter - Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    event = "VeryLazy",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "query", "python", "go", "javascript", "typescript" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- FixCursorHold - Fix for cursor hold events
  {
    "antoinemadec/FixCursorHold.nvim",
    lazy = true,
    event = "VeryLazy",
    config = function()
      vim.g.cursorhold_updatetime = 100
    end,
  },

  -- Nvim NIO - Async library for Neovim
  {
    "nvim-neotest/nvim-nio",
    lazy = true,
    event = "VeryLazy",
  },

  -- Which-Key - Keymap helper
  {
    "folke/which-key.nvim",
    lazy = true,
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Showkeys - Minimal keys screencaster for Neovim
  {
    "nvzone/showkeys",
    lazy = true,
    cmd = { "Showkeys", "ShowkeysToggle", "ShowkeysStart", "ShowkeysStop" },
    config = function()
      require("showkeys").setup({
        -- Default configuration
        timeout = 5, -- in secs
        maxkeys = 5, -- Show up to 5 keystrokes at a time
        show_count = true,
        show_all_keys = false,
        show_key_sequence = true,
        show_leader = true,
        show_which_key = true,
        position = "top-center",
      })
    end,
  },
}
