-- lua/yoda/plugins/spec/db.lua
-- Consolidated database plugin specifications

local plugins = {
  -- Vim Dadbod - Database interface
  {
    "tpope/vim-dadbod",
    lazy = true,
    cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection" },
  },

  -- Vim Dadbod UI - Database user interface
  {
    "kristijanhusak/vim-dadbod-ui",
    lazy = true,
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies = { "tpope/vim-dadbod" }, -- ✅ Explicitly declare dependency
    config = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.dbs = {
        gid = "postgresql://sun_qa@gid-qa.cvxyfczr5mcu.us-east-1.rds.amazonaws.com:8080/gid",
      }
    end,
  },

  -- Vim Dadbod Completion - Database completion
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql", "pgsql" },
    dependencies = { "tpope/vim-dadbod" },
  },
}

return plugins 