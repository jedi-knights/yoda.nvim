return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "▌" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },
    current_line_blame = true,
    current_line_blame_opts = {
      delay = 0,
      virt_text_pos = "eol",
      virt_text = { { "blame", "Comment" } },
    },
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      local function map(mode, l, r, opts)
        opts = vim.tbl_extend("force", { buffer = bufnr }, opts or {})
        vim.keymap.set(mode, l, r, opts)
      end

      map("n", "<leader>gp", gs.preview_hunk)
      map("n", "<leader>gt", gs.toggle_current_line_blame)
    end,
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup()

    vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
    vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame", {})
  end,
}
