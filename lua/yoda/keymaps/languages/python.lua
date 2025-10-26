local map = vim.keymap.set

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(ev)
    local opts = { buffer = ev.buf }

    map("n", "<leader>pr", function()
      local file = vim.fn.expand("%:p")
      local venv_ok, venv = pcall(require, "yoda.terminal.venv")
      local python_cmd = "python3"

      if venv_ok then
        local venvs = venv.find_virtual_envs()
        if #venvs > 0 then
          python_cmd = venvs[1] .. "/bin/python"
          vim.notify("Using venv: " .. venvs[1], vim.log.levels.INFO)
        end
      end

      vim.cmd("!" .. python_cmd .. " " .. file)
    end, vim.tbl_extend("force", opts, { desc = "Python: Run file" }))

    map("n", "<leader>pi", function()
      local venv_ok, venv = pcall(require, "yoda.terminal.venv")
      local python_cmd = "python3"

      if venv_ok then
        local venvs = venv.find_virtual_envs()
        if #venvs > 0 then
          python_cmd = venvs[1] .. "/bin/python"
        end
      end

      local terminal = require("snacks.terminal")
      terminal.toggle("python", {
        cmd = { python_cmd },
        win = {
          relative = "editor",
          position = "float",
          width = 0.85,
          height = 0.85,
          border = "rounded",
          title = " Python REPL ",
          title_pos = "center",
        },
      })
    end, vim.tbl_extend("force", opts, { desc = "Python: Open REPL" }))

    map("n", "<leader>pt", function()
      local ok, neotest = pcall(require, "neotest")
      if not ok then
        vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
        return
      end
      neotest.run.run()
    end, vim.tbl_extend("force", opts, { desc = "Python: Test nearest" }))

    map("n", "<leader>pT", function()
      local ok, neotest = pcall(require, "neotest")
      if not ok then
        vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
        return
      end
      neotest.run.run(vim.fn.expand("%"))
    end, vim.tbl_extend("force", opts, { desc = "Python: Test file" }))

    map("n", "<leader>pC", function()
      local ok, neotest = pcall(require, "neotest")
      if not ok then
        vim.notify("Neotest not available. Install via :Lazy sync", vim.log.levels.ERROR)
        return
      end
      neotest.run.run({ suite = true })
    end, vim.tbl_extend("force", opts, { desc = "Python: Test suite" }))

    map("n", "<leader>pd", function()
      local ok, dap_python = pcall(require, "dap-python")
      if not ok then
        vim.notify("dap-python not available. Opening standard DAP...", vim.log.levels.WARN)
        require("dap").continue()
        return
      end
      dap_python.test_method()
    end, vim.tbl_extend("force", opts, { desc = "Python: Debug test" }))

    map("n", "<leader>pD", function()
      local ok, dap_python = pcall(require, "dap-python")
      if not ok then
        vim.notify("dap-python not available", vim.log.levels.ERROR)
        return
      end
      dap_python.test_class()
    end, vim.tbl_extend("force", opts, { desc = "Python: Debug test class" }))

    map("n", "<leader>pv", function()
      local ok = pcall(vim.cmd, "VenvSelect")
      if not ok then
        vim.notify("venv-selector not available. Install via :Lazy sync", vim.log.levels.ERROR)
      end
    end, vim.tbl_extend("force", opts, { desc = "Python: Select venv" }))

    map("n", "<leader>po", function()
      local ok = pcall(vim.cmd, "AerialToggle")
      if not ok then
        vim.notify("Aerial not available. Install via :Lazy sync", vim.log.levels.ERROR)
      end
    end, vim.tbl_extend("force", opts, { desc = "Python: Toggle outline" }))

    map("n", "<leader>pe", function()
      local ok, trouble = pcall(require, "trouble")
      if not ok then
        vim.diagnostic.setloclist()
        return
      end
      vim.cmd("Trouble diagnostics toggle filter.buf=0")
    end, vim.tbl_extend("force", opts, { desc = "Python: Open diagnostics" }))

    map("n", "<leader>pm", function()
      local file = vim.fn.expand("%:p")
      vim.cmd("!mypy " .. file)
    end, vim.tbl_extend("force", opts, { desc = "Python: Run mypy" }))

    map("n", "<leader>pL", function()
      vim.cmd("ConfigurePythonLSP")
    end, vim.tbl_extend("force", opts, { desc = "Python: Configure LSP with venv" }))

    map("n", "<leader>pc", function()
      local ok = pcall(require, "coverage")
      if not ok then
        vim.notify("Coverage plugin not available", vim.log.levels.ERROR)
        return
      end
      require("coverage").load()
      require("coverage").show()
    end, vim.tbl_extend("force", opts, { desc = "Python: Show coverage" }))
  end,
})

return {}
