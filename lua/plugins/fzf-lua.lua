-- lua/plugins/fzf-lua.lua

return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  dependencies = {
    "echasnovski/mini.icons",
  },
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find Files - Fuzzy find files in current directory" },
    { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Find Text - Live grep search across files" },
    { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent Files - Browse recently opened files" },
    { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Find Buffers - Switch between open buffers" },
    {
      "<leader>fR",
      "<cmd>FzfLua lsp_document_symbols<CR>",
      desc = "Find document symbols - Search symbols in current file (any language)",
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
}
