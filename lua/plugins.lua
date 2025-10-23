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
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Navigate previous" },
    },
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
          show_hidden = true,
          win = {
            position = "left",
            width = 30,
            wo = {
              winfixwidth = true,
            },
          },
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
          diagnostics_update_in_insert = false,
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
    event = function()
      -- Only load alpha if no files were opened at startup
      if vim.fn.argc() == 0 then
        return "VimEnter"
      end
      return nil
    end,
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
        dashboard.button("a", "🤖  Open Code AI", "<leader>ai"),
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
          redraw_on_resize = false, -- Disable to prevent invalid window errors
          setup = function()
            -- Use proper scopes for options that support them
            vim.opt_local.laststatus = 0
            vim.opt_local.ruler = false
            vim.opt_local.showcmd = false
            vim.opt_local.cmdheight = 0
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
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
        notify = {
          enabled = false, -- Disable noice vim.notify override to prevent conflicts
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
          hover = {
            enabled = true,
            silent = false, -- set to true to not show a message if hover is not available
            view = "hover",
          },
          signature = {
            enabled = true,
            auto_open = {
              enabled = true,
              trigger = true,
              luasnip = true,
              throttle = 200,
            },
          },
        },
        views = {
          hover = {
            border = {
              style = "rounded",
            },
            position = { row = 2, col = 0 },
            win_options = {
              winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
            },
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
      })
    end,
  },

  -- Devicons - File type icons
  {
    "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
      require("nvim-web-devicons").setup({
        default = true,
        strict = false,
      })
    end,
  },

  -- Lualine - Statusline with git branch display
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            "branch", -- Shows current git branch
            "diff",
            "diagnostics",
          },
          lualine_c = {
            {
              function()
                return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
              end,
              icon = "📁",
            },
            "filename",
          },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "nvim-tree", "trouble", "aerial" },
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

  -- LSP Configuration using built-in vim.lsp.config (Neovim 0.11+)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      -- Setup mason-lspconfig first
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",
          "lua_ls",
          "ts_ls",
          "basedpyright",
          "yamlls",
          "omnisharp",
          "helm_ls",
          "marksman", -- Markdown LSP server
        },
      })

      -- Then setup our modern LSP configuration
      require("yoda.lsp").setup()
    end,
  },

  -- nvim-cmp - Reliable completion engine
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippet engine
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = (function()
          -- Only install jsregexp if make is available and not on problematic systems
          if vim.fn.executable("make") == 1 and jit.os ~= "Windows" then
            return "make install_jsregexp"
          end
          return nil
        end)(),
        config = function()
          -- Configure LuaSnip here to ensure it loads properly
          local luasnip = require("luasnip")

          -- Enable better snippet expansion
          luasnip.config.setup({
            history = true,
            updateevents = "TextChanged,TextChangedI",
            delete_check_events = "TextChanged,InsertLeave",
          })
        end,
        dependencies = {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
      },
      -- Completion sources
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          -- Snippet navigation
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(entry, vim_item)
            -- Kind icons
            local kind_icons = {
              Text = "󰉿",
              Method = "󰆧",
              Function = "󰊕",
              Constructor = "",
              Field = "󰜢",
              Variable = "󰀫",
              Class = "󰠱",
              Interface = "",
              Module = "",
              Property = "󰜢",
              Unit = "󰑭",
              Value = "󰎠",
              Enum = "",
              Keyword = "󰌋",
              Snippet = "",
              Color = "󰏘",
              File = "󰈙",
              Reference = "󰈇",
              Folder = "󰉋",
              EnumMember = "",
              Constant = "󰏿",
              Struct = "󰙅",
              Event = "",
              Operator = "󰆕",
              TypeParameter = "",
            }
            -- Set the icon
            vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
            -- Source name
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })

      -- Command line completion
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
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

  -- Pytest Atlas - Pytest runner with environment/marker selection
  {
    "ocrosby/pytest-atlas.nvim",
    lazy = false, -- Load immediately to ensure keymap is registered
    dependencies = {
      "folke/snacks.nvim",
    },
    config = function()
      require("pytest-atlas").setup({
        keymap = "<leader>tt",
        enable_keymap = true,
        picker = "snacks", -- Use snacks.nvim for picker
        debug = false, -- Set to true for debugging picker issues
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
      local adapters = {
        require("neotest-python")({
          dap = {
            justMyCode = false,
            console = "integratedTerminal",
          },
          args = {
            "--log-level",
            "DEBUG",
            "-vv",
            "--browser",
            "chromium",
            "--headed",
          },
          runner = "pytest",
          python = function()
            -- Auto-detect virtual environment
            local venv_ok, venv = pcall(require, "yoda.terminal.venv")
            if venv_ok then
              local venvs = venv.find_virtual_envs()
              if #venvs > 0 then
                return venvs[1] .. "/bin/python"
              end
            end
            return vim.fn.exepath("python3") or "python"
          end,
        }),
      }

      -- Add Rust adapter if available
      local rust_ok, neotest_rust = pcall(require, "neotest-rust")
      if rust_ok then
        table.insert(
          adapters,
          neotest_rust({
            args = { "--no-capture" },
            dap_adapter = "codelldb",
          })
        )
      end

      -- Add Jest adapter if available
      local jest_ok, neotest_jest = pcall(require, "neotest-jest")
      if jest_ok then
        table.insert(
          adapters,
          neotest_jest({
            jestCommand = "npm test --",
            jestConfigFile = "jest.config.js",
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end,
          })
        )
      end

      -- Add Vitest adapter if available
      local vitest_ok, neotest_vitest = pcall(require, "neotest-vitest")
      if vitest_ok then
        table.insert(adapters, neotest_vitest)
      end

      -- Add .NET adapter if available
      local dotnet_ok, neotest_dotnet = pcall(require, "neotest-dotnet")
      if dotnet_ok then
        table.insert(
          adapters,
          neotest_dotnet({
            dap = {
              adapter_name = "coreclr",
              args = { justMyCode = false },
            },
          })
        )
      end

      require("neotest").setup({
        adapters = adapters,
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

        -- Window configuration
        window = {
          width = 0.4, -- 40% of screen width
          height = 0.8, -- 80% of screen height
          position = "right", -- "left", "right", "top", "bottom"
        },

        -- Default provider and model
        -- provider = "anthropic",
        -- model = "claude-3-5-sonnet-20241022",

        -- Custom prompts
        prompts = {
          explain = "Explain @thisnd its context in detail",
          optimize = "Suggest optimizations for @this",
          test = "Write comprehensive tests for @this",
        },
      }

      -- Required for enhanced buffer management
      vim.opt.autoread = true
      vim.opt.autowrite = true -- Auto-write buffers when switching

      -- Setup OpenCode integration
      local ok, opencode_integration = pcall(require, "yoda.opencode_integration")
      if ok then
        vim.defer_fn(function()
          opencode_integration.setup()
        end, 100)
      end
    end,
  },

  -- ============================================================================
  -- UTILITIES
  -- ============================================================================

  -- Treesitter - Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "query", "python", "go", "javascript", "typescript", "rust", "toml" },
        auto_install = true,
        sync_install = false, -- Install parsers synchronously (only applied to `ensure_installed`)
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false, -- Disable vim regex highlighting for better performance
        },
        indent = { enable = true },
        -- PERFORMANCE: Limited treesitter for markdown (syntax highlighting only)
        markdown = {
          enable = true, -- Enable basic syntax highlighting
          disable = { "markdown_inline" }, -- Disable expensive inline parsing
        },
        -- Disable expensive features globally
        incremental_selection = { enable = false },
        textobjects = { enable = false },
        refactor = { enable = false },
        autotag = { enable = false },
        context_commentstring = { enable = false },
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

  -- ============================================================================
  -- RUST DEVELOPMENT
  -- ============================================================================

  -- Rust-Tools - Enhanced Rust development experience
  -- Provides inlay hints, hover actions, CodeLens, and DAP integration
  {
    "simrat39/rust-tools.nvim",
    ft = { "rust" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      local rt = require("rust-tools")
      local mason_registry = require("mason-registry")

      -- Setup rust-tools with basic configuration first
      local rust_tools_opts = {
        tools = {
          autoSetHints = true,
          inlay_hints = {
            show_parameter_hints = true,
            parameter_hints_prefix = "<- ",
            other_hints_prefix = "=> ",
            max_len_align = false,
            max_len_align_padding = 1,
            right_align = false,
            right_align_padding = 7,
          },
          hover_actions = {
            auto_focus = true,
            border = "rounded",
          },
        },
        server = {
          on_attach = function(client, bufnr)
            -- Rust-specific hover action
            vim.keymap.set("n", "K", rt.hover_actions.hover_actions, {
              buffer = bufnr,
              desc = "Rust: Hover actions",
            })

            -- Code action groups
            vim.keymap.set("n", "<leader>ca", rt.code_action_group.code_action_group, {
              buffer = bufnr,
              desc = "Rust: Code action group",
            })
          end,
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
              },
              procMacro = {
                enable = true,
              },
              checkOnSave = {
                command = "clippy",
              },
              diagnostics = {
                enable = true,
                experimental = {
                  enable = true,
                },
              },
            },
          },
        },
      }

      -- Try to setup DAP with codelldb if available
      local ok, is_installed = pcall(mason_registry.is_installed, "codelldb")
      if ok and is_installed then
        local success, codelldb_package = pcall(mason_registry.get_package, "codelldb")
        if success and codelldb_package then
          local install_ok, install_path = pcall(function()
            return codelldb_package:get_install_path()
          end)

          if install_ok and install_path then
            local codelldb_path = install_path .. "/extension/adapter/codelldb"
            local liblldb_path = install_path .. "/extension/lldb/lib/liblldb.dylib" -- macOS path

            -- Check if on Linux and adjust liblldb path
            if vim.loop.os_uname().sysname == "Linux" then
              liblldb_path = install_path .. "/extension/lldb/lib/liblldb.so"
            end

            rust_tools_opts.dap = {
              adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
            }
          else
            vim.notify("Failed to get codelldb install path. Rust debugging disabled.", vim.log.levels.WARN)
          end
        else
          vim.notify("Failed to get codelldb package from Mason registry. Rust debugging disabled.", vim.log.levels.WARN)
        end
      else
        -- Warn user that debugging won't work without codelldb
        vim.notify("codelldb not installed via Mason. Rust debugging disabled. Run :YodaRustSetup to install.", vim.log.levels.WARN)
      end

      rt.setup(rust_tools_opts)
    end,
  },

  -- Crates.nvim - Cargo.toml dependency management
  -- Shows version info, update actions in Cargo.toml files
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({
        popup = {
          autofocus = true,
          border = "rounded",
          show_version_date = true,
        },
        null_ls = {
          enabled = false, -- We're using conform.nvim + nvim-lint
        },
        completion = {
          cmp = {
            enabled = true,
          },
        },
      })

      -- Cargo.toml specific keymaps
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "Cargo.toml",
        callback = function()
          local crates = require("crates")
          local opts = { silent = true, buffer = true }

          vim.keymap.set("n", "<leader>rc", crates.show_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show popup" }))
          vim.keymap.set("n", "<leader>ru", crates.update_crate, vim.tbl_extend("force", opts, { desc = "Crates: Update crate" }))
          vim.keymap.set("n", "<leader>rU", crates.update_all_crates, vim.tbl_extend("force", opts, { desc = "Crates: Update all" }))
          vim.keymap.set("n", "<leader>rV", crates.show_versions_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show versions" }))
          vim.keymap.set("n", "<leader>rF", crates.show_features_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show features" }))
        end,
      })
    end,
  },

  -- Neotest Rust adapter
  {
    "rouge8/neotest-rust",
    lazy = true,
    dependencies = { "nvim-neotest/neotest" },
    ft = "rust",
  },

  -- Conform.nvim - Modern formatter (rustfmt, black, ruff)
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          rust = { "rustfmt" },
          lua = { "stylua" },
          python = { "ruff_format" }, -- Ruff handles formatting, linting, and import sorting
          javascript = { "biome", "prettier" }, -- Try biome first, fallback to prettier
          javascriptreact = { "biome", "prettier" },
          typescript = { "biome", "prettier" },
          typescriptreact = { "biome", "prettier" },
          json = { "biome", "prettier" },
          jsonc = { "biome", "prettier" },
          cs = { "csharpier" }, -- C# formatter
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      -- Add command to toggle format on save
      vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
        local conform = require("conform")
        if conform.will_fallback_lsp() then
          vim.notify("Format on save enabled", vim.log.levels.INFO)
        else
          vim.notify("Format on save disabled", vim.log.levels.INFO)
        end
      end, { desc = "Toggle format on save" })
    end,
  },

  -- nvim-lint - Modern linter (Clippy, ruff, mypy)
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- Configure linters by filetype
      lint.linters_by_ft = {
        rust = { "clippy" },
        python = { "ruff" }, -- Ruff handles linting, formatting, import sorting, and basic type checking
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
      }

      -- Auto-lint on certain events
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        callback = function()
          -- Only lint if linters are configured
          local linters = lint.linters_by_ft[vim.bo.filetype]
          if linters then
            lint.try_lint()
          end
        end,
      })
    end,
  },

  -- Aerial.nvim - Code outline viewer
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialNavToggle" },
    config = function()
      require("aerial").setup({
        backends = { "lsp", "treesitter", "markdown", "man" },
        layout = {
          max_width = { 40, 0.2 },
          width = nil,
          min_width = 30,
          default_direction = "prefer_right",
        },
        attach_mode = "global",
        filter_kind = false,
        show_guides = true,
        guides = {
          mid_item = "├─",
          last_item = "└─",
          nested_top = "│ ",
          whitespace = "  ",
        },
      })
    end,
  },

  -- Todo-comments.nvim - Highlight TODO/FIXME/etc
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function()
      require("todo-comments").setup({
        signs = true,
        sign_priority = 8,
        keywords = {
          FIX = {
            icon = " ",
            color = "error",
            alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
          },
          TODO = { icon = " ", color = "info" },
          HACK = { icon = " ", color = "warning" },
          WARN = {
            icon = " ",
            color = "warning",
            alt = { "WARNING", "XXX" },
          },
          PERF = {
            icon = " ",
            alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
          },
          NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
          TEST = {
            icon = "⏲ ",
            color = "test",
            alt = { "TESTING", "PASSED", "FAILED" },
          },
        },
        highlight = {
          before = "",
          keyword = "wide",
          after = "fg",
          pattern = [[.*<(KEYWORDS)\s*:]],
          comments_only = true,
        },
        search = {
          command = "rg",
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
          },
          pattern = [[\b(KEYWORDS):]],
        },
      })
    end,
  },

  -- Overseer.nvim - Task runner for cargo commands
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerInfo", "OverseerBuild" },
    config = function()
      require("overseer").setup({
        templates = { "builtin" },
        task_list = {
          direction = "bottom",
          min_height = 25,
          max_height = 25,
          default_detail = 1,
          bindings = {
            ["?"] = "ShowHelp",
            ["g?"] = "ShowHelp",
            ["<CR>"] = "RunAction",
            ["<C-e>"] = "Edit",
            ["o"] = "Open",
            ["<C-v>"] = "OpenVsplit",
            ["<C-s>"] = "OpenSplit",
            ["<C-f>"] = "OpenFloat",
            ["<C-q>"] = "OpenQuickFix",
            ["p"] = "TogglePreview",
            ["<C-l>"] = "IncreaseDetail",
            ["<C-h>"] = "DecreaseDetail",
            ["L"] = "IncreaseAllDetail",
            ["H"] = "DecreaseAllDetail",
            ["["] = "DecreaseWidth",
            ["]"] = "IncreaseWidth",
            ["{"] = "PrevTask",
            ["}"] = "NextTask",
            ["<C-k>"] = "ScrollOutputUp",
            ["<C-j>"] = "ScrollOutputDown",
          },
        },
      })
    end,
  },

  -- Mason-nvim-dap - Auto-install DAP adapters via Mason
  {
    "jay-babu/mason-nvim-dap.nvim",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "debugpy", "js-debug-adapter", "netcoredbg" },
        automatic_installation = true,
        handlers = {},
      })
    end,
  },

  -- ============================================================================
  -- PYTHON DEVELOPMENT
  -- ============================================================================

  -- nvim-dap-python - Python debugging with debugpy
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    -- Use a more reliable build command
    build = function()
      -- Install debugpy using the system python
      local result = vim.fn.system("python -m pip install debugpy")
      if vim.v.shell_error ~= 0 then
        vim.notify("Failed to install debugpy: " .. result, vim.log.levels.ERROR)
      end
    end,
    config = function()
      -- Try to find debugpy in virtual environment first
      local debugpy_path = vim.fn.exepath("python")

      -- Check for venv
      local venv_ok, venv = pcall(require, "yoda.terminal.venv")
      if venv_ok then
        local venvs = venv.find_virtual_envs()
        if #venvs > 0 then
          debugpy_path = venvs[1] .. "/bin/python"
        end
      end

      require("dap-python").setup(debugpy_path)

      -- Configure test runner
      require("dap-python").test_runner = "pytest"

      -- Add configurations for common scenarios
      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch file with arguments",
        program = "${file}",
        args = function()
          local args_string = vim.fn.input("Arguments: ")
          return vim.split(args_string, " +")
        end,
      })
    end,
  },

  -- venv-selector.nvim - Virtual environment selector
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    ft = "python",
    config = function()
      require("venv-selector").setup({
        auto_refresh = true,
        search_venv_managers = true,
        search_workspace = true,
        search = true,
        dap_enabled = true, -- Auto-configure dap-python
        parents = 2,
        name = {
          "venv",
          ".venv",
          "env",
          ".env",
        },
      })
    end,
  },

  -- ============================================================================
  -- JAVASCRIPT/TYPESCRIPT/NODE.JS DEVELOPMENT
  -- ============================================================================

  -- nvim-dap-vscode-js - VSCode JavaScript debugger
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    config = function()
      -- Get vscode-js-debug path from Mason
      local mason_registry = require("mason-registry")
      local debugger_path = mason_registry.get_package("js-debug-adapter"):get_install_path() .. "/js-debug/src/dapDebugServer.js"

      require("dap-vscode-js").setup({
        debugger_path = debugger_path,
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
      })

      -- Configure for various JavaScript scenarios
      for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        require("dap").configurations[language] = {
          -- Node.js debugging
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
          -- Jest debugging
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest Tests",
            runtimeExecutable = "node",
            runtimeArgs = {
              "./node_modules/jest/bin/jest.js",
              "--runInBand",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
          },
          -- Chrome debugging
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome",
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
          },
        }
      end
    end,
  },

  -- Neotest Jest adapter
  {
    "nvim-neotest/neotest-jest",
    dependencies = { "nvim-neotest/neotest" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  },

  -- Neotest Vitest adapter
  {
    "marilari88/neotest-vitest",
    dependencies = { "nvim-neotest/neotest" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  },

  -- Package-info.nvim - Show package versions in package.json
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = { "BufRead package.json" },
    config = function()
      require("package-info").setup({
        colors = {
          up_to_date = "#3C4048",
          outdated = "#d19a66",
        },
        icons = {
          enable = true,
          style = {
            up_to_date = "|  ",
            outdated = "|  ",
          },
        },
        autostart = true,
        hide_up_to_date = false,
        hide_unstable_versions = false,
      })

      -- Package.json specific keymaps (set in autocmd)
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "package.json",
        callback = function()
          local pkg = require("package-info")
          vim.keymap.set("n", "<leader>js", pkg.show, { desc = "JS: Show package info", buffer = true, silent = true })
          vim.keymap.set("n", "<leader>ju", pkg.update, { desc = "JS: Update package", buffer = true, silent = true })
          vim.keymap.set("n", "<leader>jd", pkg.delete, { desc = "JS: Delete package", buffer = true, silent = true })
          vim.keymap.set("n", "<leader>ji", pkg.install, { desc = "JS: Install package", buffer = true, silent = true })
          vim.keymap.set("n", "<leader>jv", pkg.change_version, { desc = "JS: Change version", buffer = true, silent = true })
        end,
      })
    end,
  },

  -- ============================================================================
  -- C# / .NET DEVELOPMENT
  -- ============================================================================

  -- Roslyn.nvim - Modern C# LSP with Roslyn
  {
    "jmederosalvarado/roslyn.nvim",
    ft = "cs",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("roslyn").setup({
        config = {
          settings = {
            ["csharp|inlay_hints"] = {
              csharp_enable_inlay_hints_for_parameters = true,
              csharp_enable_inlay_hints_for_types = true,
              csharp_enable_inlay_hints_for_implicit_object_creation = true,
              csharp_enable_inlay_hints_for_implicit_variable_types = true,
              csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            },
            ["csharp|code_lens"] = {
              dotnet_enable_references_code_lens = true,
              dotnet_enable_tests_code_lens = true,
            },
          },
        },
      })
    end,
  },

  -- Neotest .NET adapter
  {
    "Issafalcon/neotest-dotnet",
    dependencies = { "nvim-neotest/neotest" },
    ft = "cs",
  },
}
