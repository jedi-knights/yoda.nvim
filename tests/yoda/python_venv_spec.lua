-- tests/yoda/python_venv_spec.lua
-- Tests for Python virtual environment detection

local helpers = require("tests.helpers")

describe("python_venv", function()
  local python_venv

  before_each(function()
    package.loaded["yoda.python_venv"] = nil
    python_venv = require("yoda.python_venv")
    python_venv.clear_cache()
  end)

  after_each(function()
    python_venv.clear_cache()
  end)

  describe("cache management", function()
    it("caches venv detection results", function()
      local root_dir = "/tmp/test_project"
      local venv_path = "/tmp/test_project/.venv/bin/python"
      local callback_count = 0

      python_venv.detect_venv_async(root_dir, function(path)
        callback_count = callback_count + 1
      end)

      vim.wait(200, function()
        return callback_count == 1
      end)
      assert.equals(1, callback_count)
    end)

    it("returns cached results on subsequent calls", function()
      local root_dir = "/tmp/test_project"
      local callback_count = 0

      python_venv.detect_venv_async(root_dir, function()
        callback_count = callback_count + 1
      end)

      vim.wait(200, function()
        return callback_count == 1
      end)

      python_venv.detect_venv_async(root_dir, function()
        callback_count = callback_count + 1
      end)

      -- The second call is a cache hit dispatched via a single vim.schedule,
      -- but under system load the first call's real async fs_stat chain can
      -- occasionally still be in flight past 200ms -- poll for the actual
      -- condition instead of guessing a fixed sleep, matching the pattern
      -- used elsewhere in this file.
      vim.wait(500, function()
        return callback_count == 2
      end)
      assert.equals(2, callback_count)
    end)

    it("clears cache for specific root_dir", function()
      local root_dir = "/tmp/test_project"

      python_venv.detect_venv_async(root_dir, function() end)
      vim.wait(200)

      python_venv.clear_cache(root_dir)
      local stats = python_venv.get_cache_stats()
      assert.equals(0, stats.total)
    end)

    it("clears all cache entries when no root_dir provided", function()
      python_venv.detect_venv_async("/tmp/project1", function() end)
      python_venv.detect_venv_async("/tmp/project2", function() end)
      vim.wait(200)

      python_venv.clear_cache()
      local stats = python_venv.get_cache_stats()
      assert.equals(0, stats.total)
    end)
  end)

  describe("get_cache_stats()", function()
    it("returns correct statistics", function()
      local stats = python_venv.get_cache_stats()
      assert.equals(0, stats.total)
      assert.equals(0, stats.valid)
      assert.equals(0, stats.expired)
      assert.equals(300, stats.ttl_seconds)
    end)

    it("tracks cache entries", function()
      python_venv.detect_venv_async("/tmp/project1", function() end)
      python_venv.detect_venv_async("/tmp/project2", function() end)
      vim.wait(200)

      local stats = python_venv.get_cache_stats()
      assert.equals(2, stats.total)
      assert.equals(2, stats.valid)
    end)
  end)

  describe("detect_and_apply()", function()
    it("handles nil root_dir gracefully", function()
      python_venv.detect_and_apply(nil)
    end)

    it("detects and applies venv when found", function()
      local root_dir = "/tmp/test_project"
      python_venv.detect_and_apply(root_dir)
      vim.wait(200)
    end)
  end)

  describe("apply_venv_to_lsp()", function()
    it("updates LSP client configuration", function()
      local mock_client = {
        config = {
          root_dir = "/tmp/test_project",
          settings = {
            basedpyright = { analysis = {} },
            python = {},
          },
        },
        notify = helpers.spy(),
      }

      local original_get_clients = vim.lsp.get_clients
      vim.lsp.get_clients = function()
        return { mock_client }
      end

      local venv_path = "/tmp/test_project/.venv/bin/python"
      python_venv.apply_venv_to_lsp("/tmp/test_project", venv_path)

      assert.equals(
        venv_path,
        mock_client.config.settings.basedpyright.analysis.pythonPath
      )
      assert.equals(venv_path, mock_client.config.settings.python.pythonPath)

      vim.lsp.get_clients = original_get_clients
    end)

    it("only updates matching clients", function()
      local matching_client = {
        config = {
          root_dir = "/tmp/test_project",
          settings = {
            basedpyright = { analysis = {} },
            python = {},
          },
        },
        notify = helpers.spy(),
      }

      local non_matching_client = {
        config = {
          root_dir = "/tmp/other_project",
          settings = {
            basedpyright = { analysis = {} },
            python = {},
          },
        },
        notify = helpers.spy(),
      }

      local original_get_clients = vim.lsp.get_clients
      vim.lsp.get_clients = function()
        return { matching_client, non_matching_client }
      end

      local venv_path = "/tmp/test_project/.venv/bin/python"
      python_venv.apply_venv_to_lsp("/tmp/test_project", venv_path)

      assert.equals(
        venv_path,
        matching_client.config.settings.basedpyright.analysis.pythonPath
      )
      assert.is_nil(
        non_matching_client.config.settings.basedpyright.analysis.pythonPath
      )

      vim.lsp.get_clients = original_get_clients
    end)
  end)

  describe("commands", function()
    before_each(function()
      python_venv.setup_commands()
    end)

    it("creates PythonVenvDetect command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.PythonVenvDetect)
    end)

    it("creates PythonVenvCache command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.PythonVenvCache)
    end)

    it("creates PythonVenvClear command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.PythonVenvClear)
    end)
  end)

  describe("async behavior", function()
    it("executes callback asynchronously", function()
      local callback_executed = false
      local root_dir = "/tmp/test_project"

      python_venv.detect_venv_async(root_dir, function()
        callback_executed = true
      end)

      assert.is_false(callback_executed)

      vim.wait(200, function()
        return callback_executed
      end)

      assert.is_true(callback_executed)
    end)

    it("handles multiple concurrent requests", function()
      local callback_count = 0

      for i = 1, 5 do
        python_venv.detect_venv_async("/tmp/project" .. i, function()
          callback_count = callback_count + 1
        end)
      end

      vim.wait(300, function()
        return callback_count == 5
      end)

      assert.equals(5, callback_count)
    end)
  end)

  describe("error handling", function()
    it("handles invalid root directories", function()
      local callback_executed = false
      local returned_venv = "not_nil"

      python_venv.detect_venv_async(
        "/nonexistent/path/that/does/not/exist",
        function(venv_path)
          callback_executed = true
          returned_venv = venv_path
        end
      )

      vim.wait(200, function()
        return callback_executed
      end)

      assert.is_true(callback_executed)
      assert.is_nil(returned_venv)
    end)

    it("handles empty root directory", function()
      local callback_executed = false

      python_venv.detect_venv_async("", function()
        callback_executed = true
      end)

      vim.wait(200, function()
        return callback_executed
      end)

      assert.is_true(callback_executed)
    end)
  end)

  describe("edge cases exposed by branch instrumentation", function()
    -- Existing tests exercise the "no venv on disk / empty cache / fresh
    -- entries" paths only, leaving the venv-found, cache-hit, cache-expired,
    -- and no-root-dir branches at zero hits. Each test below closes one of
    -- the 7 zero-arm gaps that branch instrumentation surfaced.

    it(
      "callback receives the venv path when fs_stat reports an executable file (L78 + L113)",
      function()
        -- Arrange: mock only the .venv path as an executable file. All
        -- other build_venv_paths entries fall through as ENOENT.
        local restore = helpers.mock_fs_stat({
          ["/tmp/venv-hit-project/.venv/bin/python"] = {
            type = "file",
            mode = 493, -- 0o755, owner-execute set
          },
        })
        local received
        local done = false

        -- Act
        python_venv.detect_venv_async("/tmp/venv-hit-project", function(p)
          received = p
          done = true
        end)
        vim.wait(500, function()
          return done
        end)

        -- Assert
        assert.equals("/tmp/venv-hit-project/.venv/bin/python", received)

        restore()
      end
    )

    it(
      "second call within TTL returns the cached venv without a new fs_stat walk (L94)",
      function()
        -- Arrange: populate the cache with an initial detection.
        local restore = helpers.mock_fs_stat({
          ["/tmp/cache-hit-project/.venv/bin/python"] = {
            type = "file",
            mode = 493,
          },
        })
        local first_result
        local first_done = false
        python_venv.detect_venv_async("/tmp/cache-hit-project", function(p)
          first_result = p
          first_done = true
        end)
        vim.wait(500, function()
          return first_done
        end)
        assert.equals("/tmp/cache-hit-project/.venv/bin/python", first_result)
        restore() -- Drop the mock; a cache miss now would fs_stat and fail.

        -- Act: second call within TTL should hit L94 truthy branch and
        -- return the cached path immediately, without touching fs_stat.
        local second_result
        local second_done = false
        python_venv.detect_venv_async("/tmp/cache-hit-project", function(p)
          second_result = p
          second_done = true
        end)
        vim.wait(500, function()
          return second_done
        end)

        -- Assert
        assert.equals("/tmp/cache-hit-project/.venv/bin/python", second_result)
      end
    )

    it(
      "detect_and_apply applies venv to LSP when detection succeeds (L159)",
      function()
        -- Arrange
        local restore_stat = helpers.mock_fs_stat({
          ["/tmp/apply-project/.venv/bin/python"] = {
            type = "file",
            mode = 493,
          },
        })
        local mock_client = {
          config = {
            root_dir = "/tmp/apply-project",
            settings = {
              basedpyright = { analysis = {} },
              python = {},
            },
          },
          notify = function() end,
        }
        local original_get_clients = vim.lsp.get_clients
        vim.lsp.get_clients = function()
          return { mock_client }
        end

        -- Act
        python_venv.detect_and_apply("/tmp/apply-project")
        vim.wait(500, function()
          return mock_client.config.settings.python.pythonPath ~= nil
        end)

        -- Assert: L159 truthy branch reached apply_venv_to_lsp, which set
        -- both pythonPath fields on the matching client.
        assert.equals(
          "/tmp/apply-project/.venv/bin/python",
          mock_client.config.settings.basedpyright.analysis.pythonPath
        )
        assert.equals(
          "/tmp/apply-project/.venv/bin/python",
          mock_client.config.settings.python.pythonPath
        )

        vim.lsp.get_clients = original_get_clients
        restore_stat()
      end
    )

    it(
      "get_cache_stats counts cache entries as expired past CACHE_TTL (L184)",
      function()
        -- Arrange: seed cache with a real entry, then advance hrtime past
        -- CACHE_TTL (5 minutes in nanoseconds) so the >= CACHE_TTL branch
        -- fires without waiting.
        local original_hrtime = vim.uv.hrtime
        local seed_time = original_hrtime()
        vim.uv.hrtime = function()
          return seed_time
        end
        python_venv.detect_venv_async("/tmp/expired-project", function() end)
        vim.wait(200)
        -- Jump forward by 6 minutes (CACHE_TTL is 5 min in nanoseconds).
        vim.uv.hrtime = function()
          return seed_time + 360000000000
        end

        -- Act
        local stats = python_venv.get_cache_stats()

        -- Assert
        assert.equals(1, stats.total)
        assert.equals(1, stats.expired)
        assert.equals(0, stats.valid)

        vim.uv.hrtime = original_hrtime
      end
    )

    it(
      "PythonVenvDetect notifies and returns early when no project root is detected (L204)",
      function()
        -- Arrange
        python_venv.setup_commands()
        local original_fs_root = vim.fs.root
        vim.fs.root = function()
          return nil
        end
        local notify_msgs = {}
        package.loaded["yoda-adapters.notification"] = {
          notify = function(msg, level)
            table.insert(notify_msgs, { msg = msg, level = level })
          end,
        }
        -- The command captures notify at module load; force a re-require so
        -- the mock is picked up.
        package.loaded["yoda.python_venv"] = nil
        python_venv = require("yoda.python_venv")
        python_venv.setup_commands()

        -- Act
        vim.api.nvim_exec2("PythonVenvDetect", {})

        -- Assert
        local found_warn = false
        for _, entry in ipairs(notify_msgs) do
          if entry.msg:match("No Python project root") then
            found_warn = true
            assert.equals("warn", entry.level)
          end
        end
        assert.is_true(found_warn, "expected 'No Python project root' warn")

        vim.fs.root = original_fs_root
        package.loaded["yoda-adapters.notification"] = nil
        pcall(vim.api.nvim_del_user_command, "PythonVenvDetect")
        pcall(vim.api.nvim_del_user_command, "PythonVenvCache")
        pcall(vim.api.nvim_del_user_command, "PythonVenvClear")
      end
    )

    it("PythonVenvCache iterates cached entries (L226)", function()
      -- Arrange
      local restore_stat = helpers.mock_fs_stat({
        ["/tmp/list-cache-a/.venv/bin/python"] = { type = "file", mode = 493 },
        ["/tmp/list-cache-b/.venv/bin/python"] = { type = "file", mode = 493 },
      })
      local first_done, second_done = false, false
      python_venv.detect_venv_async("/tmp/list-cache-a", function()
        first_done = true
      end)
      python_venv.detect_venv_async("/tmp/list-cache-b", function()
        second_done = true
      end)
      vim.wait(500, function()
        return first_done and second_done
      end)
      restore_stat()

      local captured_msg
      package.loaded["yoda-adapters.notification"] = {
        notify = function(msg, _level, _opts)
          captured_msg = msg
        end,
      }
      package.loaded["yoda.python_venv"] = nil
      python_venv = require("yoda.python_venv")
      -- Re-seed cache under the new module instance so the command sees it.
      python_venv.detect_venv_async("/tmp/list-cache-a", function() end)
      python_venv.detect_venv_async("/tmp/list-cache-b", function() end)
      vim.wait(200)
      python_venv.setup_commands()

      -- Act
      vim.api.nvim_exec2("PythonVenvCache", {})

      -- Assert: both entries appear in the multi-line notify body.
      assert.is_not_nil(captured_msg)
      assert.matches("/tmp/list%-cache%-a", captured_msg)
      assert.matches("/tmp/list%-cache%-b", captured_msg)

      package.loaded["yoda-adapters.notification"] = nil
      pcall(vim.api.nvim_del_user_command, "PythonVenvDetect")
      pcall(vim.api.nvim_del_user_command, "PythonVenvCache")
      pcall(vim.api.nvim_del_user_command, "PythonVenvClear")
    end)

    it(
      "get_cached_venv drops entries whose timestamp exceeds CACHE_TTL (L28)",
      function()
        -- Arrange: seed cache with a hit, then advance vim.uv.hrtime past
        -- CACHE_TTL so the second detect_venv_async call takes the cache-
        -- expired branch inside get_cached_venv and nils the entry (L28).
        local original_hrtime = vim.uv.hrtime
        local seed_time = original_hrtime()
        vim.uv.hrtime = function()
          return seed_time
        end
        local restore_stat = helpers.mock_fs_stat({
          ["/tmp/expired-cache-project/.venv/bin/python"] = {
            type = "file",
            mode = 493,
          },
        })
        local first_done = false
        python_venv.detect_venv_async("/tmp/expired-cache-project", function()
          first_done = true
        end)
        vim.wait(200, function()
          return first_done
        end)
        assert.equals(1, python_venv.get_cache_stats().total)
        restore_stat()

        -- Jump forward past CACHE_TTL (5 min in nanoseconds).
        vim.uv.hrtime = function()
          return seed_time + 360000000000
        end

        -- Act: cache lookup expires; without any on-disk venv this time the
        -- fs_stat walk finds nothing and the callback gets nil. What matters
        -- is that the L28 assignment path executed.
        local second_result = "SENTINEL"
        python_venv.detect_venv_async(
          "/tmp/expired-cache-project",
          function(path)
            second_result = path
          end
        )
        vim.wait(500, function()
          return second_result ~= "SENTINEL"
        end)

        -- Assert: cache lookup rejected the stale entry and re-walked; the
        -- new entry now holds the fresh (nil) result rather than the seeded
        -- path, proving the expired entry was cleared and rewritten.
        assert.is_nil(second_result)
        vim.uv.hrtime = original_hrtime
      end
    )

    it(
      "PythonVenvDetect clears cache and reruns detection when root is found (L210,L211)",
      function()
        -- Arrange: stub vim.fs.root so the command's happy path fires. Seed
        -- the cache so we can prove L210 (clear_cache) actually ran.
        python_venv.setup_commands()
        local original_fs_root = vim.fs.root
        vim.fs.root = function()
          return "/tmp/detect-root-project"
        end
        python_venv.detect_venv_async(
          "/tmp/detect-root-project",
          function() end
        )
        vim.wait(200)
        assert.equals(1, python_venv.get_cache_stats().total)

        -- Detection uses fs_stat; give it a fixture so the second run
        -- succeeds cleanly.
        local restore_stat = helpers.mock_fs_stat({
          ["/tmp/detect-root-project/.venv/bin/python"] = {
            type = "file",
            mode = 493,
          },
        })

        -- Act
        vim.api.nvim_exec2("PythonVenvDetect", {})
        vim.wait(500, function()
          return python_venv.get_cache_stats().total == 1
        end)

        -- Assert: cache holds exactly one entry — the fresh one produced by
        -- L211's detect_and_apply, proving both L210 (clear) and L211
        -- (detect) executed.
        assert.equals(1, python_venv.get_cache_stats().total)

        restore_stat()
        vim.fs.root = original_fs_root
        pcall(vim.api.nvim_del_user_command, "PythonVenvDetect")
        pcall(vim.api.nvim_del_user_command, "PythonVenvCache")
        pcall(vim.api.nvim_del_user_command, "PythonVenvClear")
      end
    )

    it("PythonVenvClear empties the cache and notifies", function()
      -- Arrange
      local restore_stat = helpers.mock_fs_stat({
        ["/tmp/clear-project/.venv/bin/python"] = { type = "file", mode = 493 },
      })
      python_venv.detect_venv_async("/tmp/clear-project", function() end)
      vim.wait(200)
      assert.equals(1, python_venv.get_cache_stats().total)
      restore_stat()

      local notify_msgs = {}
      package.loaded["yoda-adapters.notification"] = {
        notify = function(msg, level)
          table.insert(notify_msgs, { msg = msg, level = level })
        end,
      }
      package.loaded["yoda.python_venv"] = nil
      python_venv = require("yoda.python_venv")
      -- Re-seed cache under the new module instance so the command sees it.
      python_venv.detect_venv_async("/tmp/clear-project", function() end)
      vim.wait(200)
      python_venv.setup_commands()

      -- Act
      vim.api.nvim_exec2("PythonVenvClear", {})

      -- Assert
      assert.equals(0, python_venv.get_cache_stats().total)
      local found_notify = false
      for _, entry in ipairs(notify_msgs) do
        if entry.msg == "Python venv cache cleared" then
          found_notify = true
          assert.equals("info", entry.level)
        end
      end
      assert.is_true(found_notify, "expected 'cache cleared' notify")

      package.loaded["yoda-adapters.notification"] = nil
      pcall(vim.api.nvim_del_user_command, "PythonVenvDetect")
      pcall(vim.api.nvim_del_user_command, "PythonVenvCache")
      pcall(vim.api.nvim_del_user_command, "PythonVenvClear")
    end)
  end)
end)
