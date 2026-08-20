-- tests/yoda/large_file_spec.lua
-- Unit tests for lua/yoda/large_file.lua, a backwards-compat shim that
-- re-exports lua/yoda/ui/large_file.lua verbatim -- both module names
-- resolve to the same table, so these tests exercise the real
-- implementation.
local helpers = require("tests.helpers")

local LargeFile = require("yoda.large_file")

describe("large_file", function()
  local buf

  before_each(function()
    LargeFile.setup({}) -- reset to defaults
    buf = vim.api.nvim_create_buf(false, true)
  end)

  after_each(function()
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end)

  -- =========================================================================
  describe("get_config()", function()
    it("returns default config", function()
      local cfg = LargeFile.get_config()
      assert.is_not_nil(cfg)
      assert.equals(100 * 1024, cfg.size_threshold)
      assert.is_true(cfg.show_notification)
    end)
  end)

  -- =========================================================================
  describe("setup()", function()
    it("merges user config over defaults", function()
      LargeFile.setup({ size_threshold = 512 * 1024 })
      local cfg = LargeFile.get_config()
      assert.equals(512 * 1024, cfg.size_threshold)
      -- Other defaults preserved
      assert.is_true(cfg.disable.lsp)
    end)

    it("handles nil config gracefully", function()
      local ok = pcall(LargeFile.setup, nil)
      assert.is_true(ok)
    end)

    it("deep merges disable table", function()
      LargeFile.setup({ disable = { lsp = false } })
      local cfg = LargeFile.get_config()
      assert.is_false(cfg.disable.lsp)
      -- Other disable flags preserved
      assert.is_true(cfg.disable.treesitter)
    end)
  end)

  -- =========================================================================
  describe("is_large_file()", function()
    it("returns false for a new buffer", function()
      assert.is_false(LargeFile.is_large_file(buf))
    end)

    it("returns true after enable_large_file_mode()", function()
      LargeFile.enable_large_file_mode(buf, 200 * 1024)
      assert.is_true(LargeFile.is_large_file(buf))
    end)

    it("returns false after disable_large_file_mode()", function()
      LargeFile.enable_large_file_mode(buf, 200 * 1024)
      LargeFile.disable_large_file_mode(buf)
      assert.is_false(LargeFile.is_large_file(buf))
    end)
  end)

  -- =========================================================================
  describe("enable_large_file_mode()", function()
    it("sets large_file buffer var to true", function()
      LargeFile.enable_large_file_mode(buf, 150 * 1024)
      assert.is_true(vim.b[buf].large_file)
    end)

    it("records the file size", function()
      LargeFile.enable_large_file_mode(buf, 150 * 1024)
      assert.equals(150 * 1024, vim.b[buf].large_file_size)
    end)

    it("is idempotent — second call is a no-op", function()
      LargeFile.enable_large_file_mode(buf, 150 * 1024)
      -- Change the size directly to verify the second call doesn't overwrite
      vim.b[buf].large_file_size = 999
      LargeFile.enable_large_file_mode(buf, 200 * 1024)
      assert.equals(999, vim.b[buf].large_file_size)
    end)
  end)

  -- =========================================================================
  describe("disable_large_file_mode()", function()
    it("clears the large_file marker", function()
      LargeFile.enable_large_file_mode(buf, 150 * 1024)
      LargeFile.disable_large_file_mode(buf)
      assert.is_false(vim.b[buf].large_file)
    end)

    it("is a no-op on a non-large-file buffer", function()
      -- Should not raise
      local ok = pcall(LargeFile.disable_large_file_mode, buf)
      assert.is_true(ok)
    end)
  end)

  -- =========================================================================
  describe("should_skip_autosave()", function()
    it("returns false when autosave disable is off", function()
      LargeFile.setup({ disable = { autosave = false } })
      LargeFile.enable_large_file_mode(buf, 200 * 1024)
      assert.is_false(LargeFile.should_skip_autosave(buf))
    end)

    it("returns true for large file when autosave disable is on", function()
      LargeFile.setup({ disable = { autosave = true } })
      LargeFile.enable_large_file_mode(buf, 200 * 1024)
      assert.is_true(LargeFile.should_skip_autosave(buf))
    end)

    it(
      "returns false for normal buffer even when autosave disable is on",
      function()
        LargeFile.setup({ disable = { autosave = true } })
        assert.is_false(LargeFile.should_skip_autosave(buf))
      end
    )
  end)

  -- =========================================================================
  describe("on_buf_read()", function()
    it("enables large file mode when size exceeds threshold", function()
      -- Mock vim.uv.fs_stat to return a large file
      local original = vim.uv.fs_stat
      vim.uv.fs_stat = function(path)
        return { size = 200 * 1024 }
      end

      vim.api.nvim_buf_set_name(buf, "/fake/large_file.lua")
      LargeFile.on_buf_read(buf)

      vim.uv.fs_stat = original
      assert.is_true(LargeFile.is_large_file(buf))
    end)

    it("does not enable large file mode for small files", function()
      local original = vim.uv.fs_stat
      vim.uv.fs_stat = function(path)
        return { size = 10 * 1024 }
      end

      vim.api.nvim_buf_set_name(buf, "/fake/small_file.lua")
      LargeFile.on_buf_read(buf)

      vim.uv.fs_stat = original
      assert.is_false(LargeFile.is_large_file(buf))
    end)

    it("does not crash when filepath is empty", function()
      local ok = pcall(LargeFile.on_buf_read, buf)
      assert.is_true(ok)
    end)
  end)

  -- =========================================================================
  describe("setup_commands()", function()
    it("registers LargeFile user commands without error", function()
      local ok = pcall(LargeFile.setup_commands)
      assert.is_true(ok)
      -- Commands should now exist
      assert.is_not_nil(vim.api.nvim_get_commands({})["LargeFileEnable"])
      assert.is_not_nil(vim.api.nvim_get_commands({})["LargeFileDisable"])
      assert.is_not_nil(vim.api.nvim_get_commands({})["LargeFileStatus"])
      assert.is_not_nil(vim.api.nvim_get_commands({})["LargeFileConfig"])
    end)

    describe("command bodies", function()
      local notify_spy_fn, notify_spy_data
      local original_notify_fn

      before_each(function()
        -- ui/large_file.lua captured `local notify =
        -- require("yoda-adapters.notification")` once at module load, long
        -- before this test runs, so replacing package.loaded's entry has
        -- no effect on that already-bound reference. Mutate the existing
        -- table's `notify` field in place instead.
        notify_spy_fn, notify_spy_data = helpers.spy()
        local notification = package.loaded["yoda-adapters.notification"]
        original_notify_fn = notification.notify
        notification.notify = notify_spy_fn
        LargeFile.setup_commands()
      end)

      after_each(function()
        package.loaded["yoda-adapters.notification"].notify = original_notify_fn
      end)

      it(
        "LargeFileEnable enables large-file mode for the current buffer",
        function()
          -- Arrange
          vim.api.nvim_set_current_buf(buf)
          vim.api.nvim_buf_set_name(buf, "/tmp/yoda_large_file_enable.lua")

          -- Act
          vim.api.nvim_exec2("LargeFileEnable", {})

          -- Assert
          assert.is_true(LargeFile.is_large_file(buf))
        end
      )

      it(
        "LargeFileDisable disables large-file mode for the current buffer",
        function()
          -- Arrange
          LargeFile.enable_large_file_mode(buf, 200 * 1024)
          vim.api.nvim_set_current_buf(buf)

          -- Act
          vim.api.nvim_exec2("LargeFileDisable", {})

          -- Assert
          assert.is_false(LargeFile.is_large_file(buf))
        end
      )

      it(
        "LargeFileStatus reports ENABLED with size and threshold when active",
        function()
          -- Arrange
          LargeFile.enable_large_file_mode(buf, 200 * 1024)
          vim.api.nvim_set_current_buf(buf)
          vim.api.nvim_buf_set_name(buf, "/tmp/yoda_large_file_status.lua")

          -- Act
          vim.api.nvim_exec2("LargeFileStatus", {})

          -- Assert
          assert.matches("ENABLED", notify_spy_data.last_call[1])
          assert.matches(
            "yoda_large_file_status%.lua",
            notify_spy_data.last_call[1]
          )
        end
      )

      it("LargeFileStatus reports DISABLED when inactive", function()
        -- Arrange
        vim.api.nvim_set_current_buf(buf)

        -- Act
        vim.api.nvim_exec2("LargeFileStatus", {})

        -- Assert
        assert.matches("DISABLED", notify_spy_data.last_call[1])
      end)

      it("LargeFileConfig notifies the current configuration", function()
        -- Act
        vim.api.nvim_exec2("LargeFileConfig", {})

        -- Assert
        assert.matches("size_threshold", notify_spy_data.last_call[1])
      end)
    end)
  end)

  -- =========================================================================
  describe("setup()'s BufReadPre autocmd", function()
    it("registers a callback that delegates to on_buf_read", function()
      -- Arrange
      LargeFile.setup({})
      local original = vim.uv.fs_stat
      vim.uv.fs_stat = function()
        return { size = 200 * 1024 }
      end
      vim.api.nvim_buf_set_name(buf, "/fake/autocmd_large_file.lua")
      local callback = vim.api.nvim_get_autocmds({
        group = "YodaLargeFile",
        event = "BufReadPre",
      })[1].callback

      -- Act
      callback({ buf = buf })

      -- Assert
      assert.is_true(LargeFile.is_large_file(buf))

      vim.uv.fs_stat = original
    end)
  end)

  -- =========================================================================
  describe("scheduled feature disabling", function()
    before_each(function()
      LargeFile.setup({})
    end)

    after_each(function()
      package.loaded["nvim-treesitter.highlight"] = nil
      package.loaded.gitsigns = nil
    end)

    it("detaches treesitter highlighting after the buffer settles", function()
      -- Arrange
      local detach_spy, detach_data = helpers.spy()
      package.loaded["nvim-treesitter.highlight"] = { detach = detach_spy }

      -- Act
      LargeFile.enable_large_file_mode(buf, 200 * 1024)
      vim.wait(50, function()
        return detach_data.called
      end)

      -- Assert
      helpers.assert_called_with(detach_data, buf)
    end)

    it(
      "does not error when nvim-treesitter.highlight is unavailable",
      function()
        -- Act
        LargeFile.enable_large_file_mode(buf, 200 * 1024)
        local ok = pcall(vim.wait, 50)

        -- Assert
        assert.is_true(ok)
      end
    )

    it("detaches every LSP client attached to the buffer", function()
      -- Arrange
      local detach_spy, detach_data = helpers.spy()
      local client = { id = 1, detach = detach_spy }
      local original_get_clients = vim.lsp.get_clients
      vim.lsp.get_clients = function()
        return { client }
      end

      -- Act
      LargeFile.enable_large_file_mode(buf, 200 * 1024)
      vim.wait(50, function()
        return detach_data.called
      end)

      -- Assert: client:detach(buf) passes `client` as the implicit self arg
      helpers.assert_called_with(detach_data, client, buf)

      vim.lsp.get_clients = original_get_clients
    end)

    it("detaches gitsigns when it is loaded", function()
      -- Arrange
      local detach_spy, detach_data = helpers.spy()
      package.loaded.gitsigns = { detach = detach_spy }

      -- Act
      LargeFile.enable_large_file_mode(buf, 200 * 1024)
      vim.wait(50, function()
        return detach_data.called
      end)

      -- Assert
      helpers.assert_called_with(detach_data, buf)
    end)

    it("does not error when gitsigns is not loaded", function()
      -- Act
      LargeFile.enable_large_file_mode(buf, 200 * 1024)
      local ok = pcall(vim.wait, 50)

      -- Assert
      assert.is_true(ok)
    end)
  end)
end)
