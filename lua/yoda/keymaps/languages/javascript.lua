local map = vim.keymap.set

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function(ev)
    local opts = { buffer = ev.buf }

    map("n", "<leader>jr", function()
      local file = vim.fn.expand("%:p")
      vim.cmd("!node " .. file)
    end, vim.tbl_extend("force", opts, { desc = "JavaScript: Run file with Node" }))

    map("n", "<leader>jn", function()
      local terminal = require("snacks.terminal")
      terminal.toggle("node", {
        cmd = { "node" },
        win = {
          relative = "editor",
          position = "float",
          width = 0.85,
          height = 0.85,
          border = "rounded",
          title = " Node.js REPL ",
          title_pos = "center",
        },
      })
    end, vim.tbl_extend("force", opts, { desc = "JavaScript: Open Node REPL" }))

    map("n", "<leader>jt", function()
      local ok, neotest = pcall(require, "neotest")
      if not ok then
        vim.notify("Neotest not available", vim.log.levels.ERROR)
        return
      end
      neotest.run.run()
    end, vim.tbl_extend("force", opts, { desc = "JavaScript: Test nearest" }))

    map("n", "<leader>jT", function()
      local ok, neotest = pcall(require, "neotest")
      if not ok then
        vim.notify("Neotest not available", vim.log.levels.ERROR)
        return
      end
      neotest.run.run(vim.fn.expand("%"))
    end, vim.tbl_extend("force", opts, { desc = "JavaScript: Test file" }))

    map("n", "<leader>jd", function()
      local ok, neotest = pcall(require, "neotest")
      if not ok then
        vim.notify("Neotest not available", vim.log.levels.ERROR)
        return
      end
      neotest.run.run({ strategy = "dap" })
    end, vim.tbl_extend("force", opts, { desc = "JavaScript: Debug test" }))

    map("n", "<leader>jo", function()
      local ok = pcall(vim.cmd, "AerialToggle")
      if not ok then
        vim.notify("Aerial not available", vim.log.levels.ERROR)
      end
    end, vim.tbl_extend("force", opts, { desc = "JavaScript: Toggle outline" }))

    map("n", "<leader>je", function()
      local ok, trouble = pcall(require, "trouble")
      if not ok then
        vim.diagnostic.setloclist()
        return
      end
      vim.cmd("Trouble diagnostics toggle filter.buf=0")
    end, vim.tbl_extend("force", opts, { desc = "JavaScript: Open diagnostics" }))

    map("n", "<leader>jl", function()
      vim.cmd("EslintFixAll")
    end, vim.tbl_extend("force", opts, { desc = "JavaScript: ESLint fix all" }))

    map("n", "<leader>ji", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source.addMissingImports.ts" },
          diagnostics = {},
        },
      })
    end, vim.tbl_extend("force", opts, { desc = "JavaScript: Add missing imports" }))

    map("n", "<leader>jI", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source.removeUnused.ts" },
          diagnostics = {},
        },
      })
    end, vim.tbl_extend("force", opts, { desc = "JavaScript: Remove unused imports" }))
  end,
})

return {}
