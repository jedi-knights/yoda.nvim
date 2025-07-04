return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = {
      marks = true,     -- shows a list of your marks on ' and `
      registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      spelling = {
        enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
        suggestions = 20, -- how many suggestions should be shown in the list?
      },
      -- the presets plugin, adds help for a bunch of default keybindings in Neovim
      -- No actual key bindings are created
      presets = {
        operators = false,    -- adds help for operators like d, y, ... and registers them for motion / text object completion
        motions = true,       -- adds help for motions
        text_objects = true,  -- help for text objects triggered after entering an operator
        windows = true,       -- default bindings on <c-w>
        nav = true,          -- misc bindings to work with windows
        z = true,            -- bindings for folds, spelling and others prefixed with z
        g = true,            -- bindings for prefixed with g
      },
    },
    -- add operators that will trigger motion and text object completion
    -- to enable all native operators, set the preset / operators plugin above
    operators = { gc = "Comments" },
    key_labels = {
      -- override the label used to display some keys. It doesn't effect WK in any other way.
      -- For example:
      -- ["<space>"] = "SPC",
      -- ["<cr>"] = "RET",
      -- ["<tab>"] = "TAB",
    },
    icons = {
      breadcrumb = "»", -- symbol used in the command line area that shows your current key combo
      separator = "➜", -- symbol used between a key and it's label
      group = "+", -- symbol prepended to a group
    },
    popup_mappings = {
      scroll_down = "<c-d>", -- binding to scroll down inside the popup
      scroll_up = "<c-u>",   -- binding to scroll up inside the popup
    },
    window = {
      border = "rounded", -- none, single, double, shadow, rounded
      position = "bottom", -- bottom, top
      margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]. When between 0 and 1, will be treated as a percentage of the screen size.
      padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
      winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
      zindex = 1000, -- positive value to position WhichKey above other floating windows.
    },
    layout = {
      height = { min = 4, max = 25 }, -- min and max height of the columns
      width = { min = 20, max = 50 }, -- min and max width of the columns
      spacing = 3, -- spacing between columns
      align = "left", -- align columns left, center or right
    },
    ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
    show_help = true, -- show a help message in the command line for using WhichKey
    show_keys = true, -- show the currently pressed key and its label as a message in the command line
    triggers = "auto", -- automatically setup triggers
    -- triggers = {"<leader>"} -- or specify a list manually
    triggers_blacklist = {
      -- list of mode / prefixes that should never be hooked by WhichKey
      -- this is mostly relevant for keymaps that start with a native binding
      -- most people should not need to change this
      i = { "j", "k" },
      v = { "j", "k" },
    },
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    
    -- Register key groups
    wk.register({
      ["<leader>"] = {
        -- LSP
        l = {
          name = "LSP",
          d = "Go to Definition",
          D = "Go to Declaration", 
          i = "Go to Implementation",
          r = "Find References",
          rn = "Rename Symbol",
          a = "Code Action",
          s = "Document Symbols",
          w = "Workspace Symbols",
          f = "Format Buffer",
          e = "Show Diagnostics",
          q = "Set Loclist",
        },
        -- Search
        s = {
          name = "Search",
          f = "Find Files",
          g = "Live Grep", 
          h = "Help",
          k = "Keymaps",
          d = "Diagnostics",
          r = "Resume",
          w = "Current Word",
          ["."] = "Recent Files",
        },
        -- Buffer
        b = {
          name = "Buffer",
          n = "Next Buffer",
          p = "Previous Buffer", 
          d = "Delete Buffer",
          q = "Close & Switch",
          o = "Close Others",
        },
        -- Window/Split
        ["|"] = "Vertical Split",
        ["-"] = "Horizontal Split",
        se = "Equalize Windows",
        sx = "Close Split",
        -- Terminal
        v = {
          name = "Terminal",
          t = "Toggle Terminal",
          r = "Python REPL",
        },
        -- Testing
        t = {
          name = "Test",
          a = "Run All Tests",
          n = "Run Nearest Test",
          f = "Run File Tests", 
          l = "Run Last Test",
          s = "Test Summary",
          o = "Output Panel",
          d = "Debug Test",
          v = "View Output",
        },
        -- Git
        g = {
          name = "Git",
          g = "Neogit",
          B = "Git Blame",
        },
        -- AI
        a = {
          name = "AI",
          a = "Ask Avante",
          c = "Avante Chat", 
          h = "MCP Hub",
        },
        c = {
          name = "Copilot",
          p = "Toggle Copilot",
        },
        -- Utility
        u = {
          name = "Utility",
          r = "Toggle Relative Numbers",
          s = "Toggle Spell",
          c = "Toggle Cursor Line",
          l = "Toggle Whitespace",
          w = "Toggle Word Wrap",
          f = "Format Buffer",
          d = "Toggle Diagnostics",
          h = "Clear Search",
          i = "File Info",
          t = "Toggle Terminal",
          p = "Copy File Path",
          n = "Copy File Name",
        },
        -- Explorer
        e = {
          name = "Explorer",
          t = "Toggle Explorer",
          f = "Focus Explorer",
        },
        -- Harpoon
        h = {
          name = "Harpoon",
          a = "Add File",
          m = "Toggle Menu",
          ["1"] = "File 1",
          ["2"] = "File 2", 
          ["3"] = "File 3",
          ["4"] = "File 4",
        },
        -- Coverage
        c = {
          name = "Coverage",
          v = "Show Coverage",
          x = "Hide Coverage",
        },
        -- Cargo
        c = {
          name = "Cargo",
          b = "Build",
          r = "Run",
          t = "Test",
        },
      },
      -- Navigation
      ["["] = {
        d = "Previous Diagnostic",
        m = "Previous Function",
      },
      ["]"] = {
        d = "Next Diagnostic", 
        m = "Next Function",
      },
    })
  end,
} 