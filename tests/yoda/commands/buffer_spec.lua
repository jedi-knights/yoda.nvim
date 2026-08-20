-- tests/yoda/commands/buffer_spec.lua
local helpers = require("tests.helpers")

describe("commands.buffer", function()
  local notify_spy_fn, notify_spy_data
  local cmd_spy_fn, cmd_spy_data
  local original_vim_cmd

  local function clear_commands()
    pcall(vim.api.nvim_del_user_command, "Bd")
    pcall(vim.api.nvim_del_user_command, "BD")
  end

  before_each(function()
    package.loaded["yoda.commands.buffer"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }
    -- required unconditionally at the top of :Bd's callback, before any
    -- branching, and not preloaded by minimal_init.lua
    package.loaded["yoda-window.protection"] = {
      is_buffer_switch_allowed = function()
        return true
      end,
    }

    clear_commands()
    require("yoda.commands.buffer").setup()

    original_vim_cmd = vim.cmd
    cmd_spy_fn, cmd_spy_data = helpers.spy()
  end)

  after_each(function()
    vim.cmd = original_vim_cmd
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded["yoda-window.protection"] = nil
    clear_commands()
  end)

  describe(":Bd on a non-normal buffer", function()
    local buf

    before_each(function()
      buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].buftype = "nofile"
      vim.api.nvim_set_current_buf(buf)
    end)

    after_each(function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)

    it("falls back to plain :bdelete", function()
      -- Arrange
      vim.cmd = cmd_spy_fn

      -- Act
      vim.api.nvim_exec2("Bd", {})

      -- Assert
      assert.equals("bdelete", cmd_spy_data.last_call[1])
    end)

    it("forwards the bang to :bdelete!", function()
      -- Arrange
      vim.cmd = cmd_spy_fn

      -- Act
      vim.api.nvim_exec2("Bd!", {})

      -- Assert
      assert.equals("bdelete!", cmd_spy_data.last_call[1])
    end)
  end)

  describe(
    ":Bd on a normal buffer with no other normal buffers open",
    function()
      local buf
      local unlisted = {}

      before_each(function()
        -- Neovim refuses to delete the last remaining buffer outright, so
        -- unlist every other normal buffer instead of trying to delete
        -- it -- :Bd's normal_buffers count only looks at buflisted.
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[b].buftype == "" and vim.bo[b].buflisted then
            vim.bo[b].buflisted = false
            table.insert(unlisted, b)
          end
        end
        buf = vim.api.nvim_create_buf(false, false)
        vim.api.nvim_buf_set_name(buf, "/tmp/yoda_buffer_spec_only.lua")
        vim.api.nvim_set_current_buf(buf)
      end)

      after_each(function()
        for _, b in ipairs(unlisted) do
          if vim.api.nvim_buf_is_valid(b) then
            vim.bo[b].buflisted = true
          end
        end
        unlisted = {}
      end)

      it(
        "deletes the buffer directly without redirecting any window",
        function()
          -- Act
          vim.api.nvim_exec2("Bd", {})

          -- Assert: it's the sole buffer in the sole window, so Neovim
          -- can't truly destroy it -- :bdelete unlists it and falls back
          -- to another buffer instead. That fallback (away from `buf`) is
          -- the real, observable success signal here.
          helpers.assert_not_called(notify_spy_data)
          assert.is_false(vim.bo[buf].buflisted)
          assert.is_false(buf == vim.api.nvim_get_current_buf())
        end
      )

      it("notifies an error when the delete itself fails", function()
        -- Arrange: a modified buffer with nomodifiable set makes :bdelete
        -- (without !) genuinely fail.
        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "unsaved change" })
        vim.bo[buf].modifiable = false

        -- Act
        vim.api.nvim_exec2("Bd", {})

        -- Assert
        assert.matches("Buffer delete failed", notify_spy_data.last_call[1])

        vim.bo[buf].modifiable = true
      end)
    end
  )

  describe(":Bd on a normal buffer with other normal buffers open", function()
    local buf, other_buf, win, poison
    local unlisted = {}

    before_each(function()
      -- Unlist every stray normal buffer so other_buf is guaranteed to be
      -- the only "other normal buffer" candidate for the fallback branch.
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[b].buftype == "" and vim.bo[b].buflisted then
          vim.bo[b].buflisted = false
          table.insert(unlisted, b)
        end
      end

      -- listed = true: :Bd's normal_buffers count only looks at
      -- buflisted, so other_buf must be listed to count as a candidate.
      other_buf = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_buf_set_name(other_buf, "/tmp/yoda_buffer_spec_other.lua")

      buf = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_buf_set_name(buf, "/tmp/yoda_buffer_spec_target.lua")
      win = vim.api.nvim_get_current_win()

      -- Poison the window's alternate-buffer register with a non-normal
      -- buftype buffer, excluded by :Bd's `buftype == ""` check, so every
      -- test starts from a deterministic "no valid alternate" baseline.
      poison = vim.api.nvim_create_buf(false, true)
      vim.bo[poison].buftype = "nofile"
      vim.api.nvim_win_set_buf(win, poison)
      vim.api.nvim_win_set_buf(win, buf)
    end)

    after_each(function()
      if vim.api.nvim_buf_is_valid(other_buf) then
        vim.api.nvim_buf_delete(other_buf, { force = true })
      end
      if vim.api.nvim_buf_is_valid(poison) then
        vim.api.nvim_buf_delete(poison, { force = true })
      end
      for _, b in ipairs(unlisted) do
        if vim.api.nvim_buf_is_valid(b) then
          vim.bo[b].buflisted = true
        end
      end
      unlisted = {}
    end)

    it(
      "redirects the window to the alternate buffer when it is valid",
      function()
        -- Arrange: visiting other_buf then buf again makes other_buf "#"
        vim.api.nvim_win_set_buf(win, other_buf)
        vim.api.nvim_win_set_buf(win, buf)

        -- Act
        vim.api.nvim_exec2("Bd", {})

        -- Assert: :bdelete unloads/unlists but does not wipe the buffer
        -- object, so nvim_buf_is_valid stays true by design (that's
        -- :bwipeout's job) -- is_loaded is the real success signal.
        assert.equals(other_buf, vim.api.nvim_win_get_buf(win))
        assert.is_false(vim.api.nvim_buf_is_loaded(buf))
      end
    )

    it(
      "falls back to the first other normal buffer when there is no valid alternate",
      function()
        -- Act: before_each already poisoned the alternate register
        vim.api.nvim_exec2("Bd", {})

        -- Assert
        assert.equals(other_buf, vim.api.nvim_win_get_buf(win))
      end
    )

    it(
      "skips the proactive redirect when the protection check denies it",
      function()
        -- Arrange: once :Bd's own redirect is skipped, Neovim's native
        -- :bdelete-on-the-current-buffer fallback still runs and may itself
        -- move the window or even close it -- that's Neovim's own
        -- heuristic, not something :Bd controls at that point. The signal
        -- that's actually attributable to the protection check is that :Bd
        -- never *issues* the proactive switch in the first place.
        local is_allowed_spy, is_allowed_data = helpers.spy()
        package.loaded["yoda-window.protection"].is_buffer_switch_allowed = function(
          ...
        )
          is_allowed_spy(...)
          return false
        end
        local set_buf_spy, set_buf_data = helpers.spy()
        local original_set_buf = vim.api.nvim_win_set_buf
        vim.api.nvim_win_set_buf = function(...)
          set_buf_spy(...)
          return original_set_buf(...)
        end

        -- Act
        vim.api.nvim_exec2("Bd", {})

        -- Assert
        helpers.assert_called_with(is_allowed_data, win, other_buf)
        for _, call in ipairs(set_buf_data.calls) do
          assert.is_false(call[1] == win and call[2] == other_buf)
        end

        vim.api.nvim_win_set_buf = original_set_buf
      end
    )
  end)

  it(":BD delegates to :Bd with the bang preserved", function()
    -- Arrange
    vim.cmd = cmd_spy_fn

    -- Act
    vim.api.nvim_exec2("BD!", {})

    -- Assert
    assert.equals("Bd!", cmd_spy_data.last_call[1])
  end)
end)
