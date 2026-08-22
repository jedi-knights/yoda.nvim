-- tests/yoda/git_refresh_spec.lua
-- Unit tests for lua/yoda/git_refresh.lua

describe("git_refresh", function()
  local autocmd_calls
  local augroup_calls
  local mock_autocmd
  local mock_augroup
  local captured_callbacks -- keyed by event name

  before_each(function()
    autocmd_calls = {}
    augroup_calls = {}
    captured_callbacks = {}

    mock_augroup = function(name, opts)
      table.insert(augroup_calls, { name = name, opts = opts })
      return name -- return name as the group id
    end

    mock_autocmd = function(event, opts)
      table.insert(autocmd_calls, { event = event, opts = opts })
      captured_callbacks[event] = opts.callback
    end

    -- Reset module state between tests
    package.loaded["yoda.git_refresh"] = nil
  end)

  after_each(function()
    package.loaded["yoda.git_refresh"] = nil
  end)

  -- =========================================================================
  describe("setup_autocmds()", function()
    it("creates the YodaGitRefresh augroup", function()
      local GitRefresh = require("yoda.git_refresh")
      GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)

      assert.equals(1, #augroup_calls)
      assert.equals("YodaGitRefresh", augroup_calls[1].name)
      assert.is_true(augroup_calls[1].opts.clear)
    end)

    it("registers BufWritePost autocmd", function()
      local GitRefresh = require("yoda.git_refresh")
      GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)

      local events = vim.tbl_map(function(c)
        return c.event
      end, autocmd_calls)
      assert.truthy(vim.tbl_contains(events, "BufWritePost"))
    end)

    it("registers FileChangedShell autocmd", function()
      local GitRefresh = require("yoda.git_refresh")
      GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)

      local events = vim.tbl_map(function(c)
        return c.event
      end, autocmd_calls)
      assert.truthy(vim.tbl_contains(events, "FileChangedShell"))
    end)

    it("registers FocusGained autocmd", function()
      local GitRefresh = require("yoda.git_refresh")
      GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)

      local events = vim.tbl_map(function(c)
        return c.event
      end, autocmd_calls)
      assert.truthy(vim.tbl_contains(events, "FocusGained"))
    end)

    it("registers exactly 3 autocmds", function()
      local GitRefresh = require("yoda.git_refresh")
      GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)

      assert.equals(3, #autocmd_calls)
    end)

    it("all autocmds belong to YodaGitRefresh group", function()
      local GitRefresh = require("yoda.git_refresh")
      GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)

      for _, call in ipairs(autocmd_calls) do
        assert.equals("YodaGitRefresh", call.opts.group)
      end
    end)

    it("all autocmds have a desc field", function()
      local GitRefresh = require("yoda.git_refresh")
      GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)

      for _, call in ipairs(autocmd_calls) do
        assert.is_string(call.opts.desc)
        assert.is_true(#call.opts.desc > 0)
      end
    end)
  end)

  -- =========================================================================
  describe("FileChangedShell recursion guard", function()
    it("FileChangedShell callback is a function", function()
      local GitRefresh = require("yoda.git_refresh")
      GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)

      assert.is_function(captured_callbacks["FileChangedShell"])
    end)

    it("second synchronous call is blocked while guard is active", function()
      local GitRefresh = require("yoda.git_refresh")
      GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)

      local callback = captured_callbacks["FileChangedShell"]
      local buf = vim.api.nvim_create_buf(false, true)
      local args = { buf = buf }

      -- Both calls should be safe (no error thrown)
      local ok1 = pcall(callback, args)
      local ok2 = pcall(callback, args) -- guard prevents re-entry

      assert.is_true(ok1)
      assert.is_true(ok2)

      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end)
  end)

  -- =========================================================================
  describe("autocmd callbacks trigger gitsigns.refresh_batched", function()
    -- Covers the truthy `vim.bo.buftype == ""` arms on BufWritePost (L27),
    -- FileChangedShell (L46), and FocusGained (L63). Every prior test just
    -- registers callbacks or exercises the recursion guard; none of them
    -- actually run the refresh path on a normal buffer.
    local refresh_calls
    local original_gitsigns
    local original_cmd

    before_each(function()
      refresh_calls = 0
      original_gitsigns = package.loaded["yoda.integrations.gitsigns"]
      package.loaded["yoda.integrations.gitsigns"] = {
        refresh_batched = function()
          refresh_calls = refresh_calls + 1
        end,
      }
      -- Force git_refresh to re-require gitsigns with our stub. The module
      -- captures gitsigns at load time in a local upvalue.
      package.loaded["yoda.git_refresh"] = nil
    end)

    after_each(function()
      package.loaded["yoda.integrations.gitsigns"] = original_gitsigns
      package.loaded["yoda.git_refresh"] = nil
      if original_cmd then
        vim.cmd = original_cmd
        original_cmd = nil
      end
    end)

    it(
      "BufWritePost refreshes gitsigns on a normal buffer (buftype == '')",
      function()
        -- Arrange
        local GitRefresh = require("yoda.git_refresh")
        GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = ""
        vim.api.nvim_set_current_buf(buf)

        -- Act
        captured_callbacks["BufWritePost"]({ buf = buf })

        -- Assert
        assert.equals(1, refresh_calls)

        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    )

    it(
      "BufWritePost does not refresh on a special buffer (buftype != '')",
      function()
        -- Arrange
        local GitRefresh = require("yoda.git_refresh")
        GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "nofile"
        vim.api.nvim_set_current_buf(buf)

        -- Act
        captured_callbacks["BufWritePost"]({ buf = buf })

        -- Assert
        assert.equals(0, refresh_calls)

        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    )

    it(
      "FileChangedShell refreshes on valid normal buffer via vim.schedule",
      function()
        -- Arrange
        local GitRefresh = require("yoda.git_refresh")
        GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = ""

        -- Act
        captured_callbacks["FileChangedShell"]({ buf = buf })
        vim.wait(50, function()
          return refresh_calls > 0
        end)

        -- Assert
        assert.equals(1, refresh_calls)

        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    )

    it(
      "FileChangedShell skips refresh when args.buf is an invalid buffer",
      function()
        -- Arrange
        local GitRefresh = require("yoda.git_refresh")
        GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_delete(buf, { force = true })

        -- Act
        captured_callbacks["FileChangedShell"]({ buf = buf })
        vim.wait(50)

        -- Assert
        assert.equals(0, refresh_calls)
      end
    )

    it(
      "FocusGained refreshes on a normal buffer and runs :checktime",
      function()
        -- Arrange
        local GitRefresh = require("yoda.git_refresh")
        GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = ""
        vim.api.nvim_set_current_buf(buf)
        local cmds_seen = {}
        original_cmd = vim.cmd
        -- vim.cmd is called as vim.cmd("checktime") here (function call form)
        vim.cmd = setmetatable({}, {
          __call = function(_, arg)
            table.insert(cmds_seen, arg)
          end,
        })

        -- Act
        captured_callbacks["FocusGained"]({ buf = buf })
        vim.wait(50, function()
          return refresh_calls > 0
        end)

        -- Assert
        assert.equals(1, refresh_calls)
        assert.is_true(
          vim.tbl_contains(cmds_seen, "checktime"),
          "expected vim.cmd('checktime') to fire"
        )

        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    )

    it("FocusGained does not refresh on a special buffer", function()
      -- Arrange
      local GitRefresh = require("yoda.git_refresh")
      GitRefresh.setup_autocmds(mock_autocmd, mock_augroup)
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].buftype = "nofile"
      vim.api.nvim_set_current_buf(buf)

      -- Act
      captured_callbacks["FocusGained"]({ buf = buf })
      vim.wait(50)

      -- Assert
      assert.equals(0, refresh_calls)

      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end)
  end)
end)
