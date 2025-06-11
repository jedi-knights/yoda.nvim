return {
  {
    "tpope/vim-dadbod",
    lazy = true,
    cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection" },
  },
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
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql", "pgsql" },
    dependencies = { "tpope/vim-dadbod" },
  },
}
