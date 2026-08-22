-- tests/yoda/plugins/git_spec.lua
local helpers = require("tests.helpers")

describe("plugins.git", function()
  local specs

  local function by_name(name)
    for _, spec in ipairs(specs) do
      if spec[1] == name then
        return spec
      end
    end
    return nil
  end

  before_each(function()
    package.loaded["yoda.plugins.git"] = nil
    specs = require("yoda.plugins.git")
  end)

  after_each(function()
    package.loaded.gitsigns = nil
    package.loaded.diffview = nil
    package.loaded.neogit = nil
  end)

  it("declares gitsigns, diffview, and neogit", function()
    -- Assert
    assert.is_not_nil(by_name("lewis6991/gitsigns.nvim"))
    assert.is_not_nil(by_name("sindrets/diffview.nvim"))
    assert.is_not_nil(by_name("NeogitOrg/neogit"))
  end)

  describe("gitsigns", function()
    local gitsigns_spec
    local gs

    local function fresh_gs()
      return {
        refresh = function() end,
        next_hunk = function() end,
        prev_hunk = function() end,
        stage_buffer = function() end,
        undo_stage_hunk = function() end,
        reset_buffer = function() end,
        preview_hunk = function() end,
        blame_line = function() end,
        toggle_current_line_blame = function() end,
        diffthis = function() end,
        toggle_deleted = function() end,
      }
    end

    before_each(function()
      gitsigns_spec = by_name("lewis6991/gitsigns.nvim")
      gs = fresh_gs()
      package.loaded.gitsigns = gs
      pcall(
        vim.api.nvim_clear_autocmds,
        { event = "User", pattern = "NeogitStatusRefreshed" }
      )
      pcall(
        vim.api.nvim_clear_autocmds,
        { event = "User", pattern = "NeogitCommitComplete" }
      )
      pcall(
        vim.api.nvim_clear_autocmds,
        { event = "User", pattern = "NeogitPushComplete" }
      )
    end)

    it("configures signs, blame, and debounce settings", function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      gs.setup = setup_spy

      -- Act
      gitsigns_spec.config()

      -- Assert
      local opts = setup_data.last_call[1]
      assert.equals("│", opts.signs.add.text)
      assert.is_true(opts.current_line_blame)
      assert.equals(800, opts.current_line_blame_opts.delay)
      assert.equals("function", type(opts.on_attach))
    end)

    describe("on_attach(bufnr)", function()
      local buf, on_attach

      before_each(function()
        local setup_spy, setup_data = helpers.spy()
        gs.setup = setup_spy
        gitsigns_spec.config()
        on_attach = setup_data.last_call[1].on_attach
        buf = vim.api.nvim_create_buf(false, true)
        on_attach(buf)
      end)

      after_each(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end)

      -- Searches by desc, not lhs: <leader> expands to mapleader (default
      -- "\" when unset in tests), so a literal "<leader>hS" never matches
      -- the real expanded lhs.
      local function find_keymap_by_desc(mode, desc)
        for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
          if km.desc == desc then
            return km
          end
        end
        return nil
      end

      local function find_keymap(mode, lhs)
        for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
          if km.lhs == lhs then
            return km
          end
        end
        return nil
      end

      it("refreshes gitsigns after neogit status/commit/push events", function()
        -- Arrange
        local refresh_spy, refresh_data = helpers.spy()
        gs.refresh = refresh_spy

        -- Act: minimal_init.lua sets eventignore=all for test speed, which
        -- also suppresses User autocmds -- lift it just long enough to fire
        -- these.
        local original_eventignore = vim.o.eventignore
        vim.o.eventignore = ""
        vim.api.nvim_exec_autocmds(
          "User",
          { pattern = "NeogitStatusRefreshed" }
        )
        vim.api.nvim_exec_autocmds("User", { pattern = "NeogitCommitComplete" })
        vim.api.nvim_exec_autocmds("User", { pattern = "NeogitPushComplete" })
        vim.o.eventignore = original_eventignore

        -- Assert
        assert.equals(3, refresh_data.call_count)
      end)

      it(
        "]c jumps straight to the next diff hunk when already diffing",
        function()
          -- Arrange
          vim.wo.diff = true
          local km = find_keymap("n", "]c")

          -- Act
          local result = km.callback()

          -- Assert
          assert.equals("]c", result)

          vim.wo.diff = false
        end
      )

      it("]c schedules the next git hunk when not diffing", function()
        -- Arrange
        local next_hunk_spy, next_hunk_data = helpers.spy()
        gs.next_hunk = next_hunk_spy
        local km = find_keymap("n", "]c")

        -- Act
        local result = km.callback()
        vim.wait(50, function()
          return next_hunk_data.called
        end)

        -- Assert
        assert.equals("<Ignore>", result)
        helpers.assert_called(next_hunk_data, 1)
      end)

      it("[c schedules the previous git hunk when not diffing", function()
        -- Arrange
        local prev_hunk_spy, prev_hunk_data = helpers.spy()
        gs.prev_hunk = prev_hunk_spy
        local km = find_keymap("n", "[c")

        -- Act
        km.callback()
        vim.wait(50, function()
          return prev_hunk_data.called
        end)

        -- Assert
        helpers.assert_called(prev_hunk_data, 1)
      end)

      it("binds direct gitsigns methods without an extra wrapper", function()
        -- Assert
        assert.equals(
          gs.stage_buffer,
          find_keymap_by_desc("n", "Git: Stage buffer").callback
        )
        assert.equals(
          gs.undo_stage_hunk,
          find_keymap_by_desc("n", "Git: Undo stage hunk").callback
        )
        assert.equals(
          gs.reset_buffer,
          find_keymap_by_desc("n", "Git: Reset buffer").callback
        )
        assert.equals(
          gs.preview_hunk,
          find_keymap_by_desc("n", "Git: Preview hunk").callback
        )
        assert.equals(
          gs.toggle_current_line_blame,
          find_keymap_by_desc("n", "Git: Toggle line blame").callback
        )
        assert.equals(
          gs.diffthis,
          find_keymap_by_desc("n", "Git: Diff this").callback
        )
        assert.equals(
          gs.toggle_deleted,
          find_keymap_by_desc("n", "Git: Toggle deleted lines").callback
        )
      end)

      it("<leader>hb shows the full blame for the current line", function()
        -- Arrange
        local blame_spy, blame_data = helpers.spy()
        gs.blame_line = blame_spy

        -- Act
        find_keymap_by_desc("n", "Git: Blame line (full)").callback()

        -- Assert
        helpers.assert_called_with(blame_data, { full = true })
      end)

      it("<leader>hD diffs against the last commit", function()
        -- Arrange
        local diffthis_spy, diffthis_data = helpers.spy()
        gs.diffthis = diffthis_spy

        -- Act
        find_keymap_by_desc("n", "Git: Diff this (against last commit)").callback()

        -- Assert
        helpers.assert_called_with(diffthis_data, "~")
      end)

      it(
        "[c returns the literal '[c' when the buffer is in diff mode (L94 truthy)",
        function()
          -- Arrange
          local original_diff = vim.wo.diff
          vim.wo.diff = true
          local cb = find_keymap_by_desc("n", "Git: Prev hunk").callback

          -- Act
          local result = cb()

          -- Assert
          assert.equals("[c", result)

          vim.wo.diff = original_diff
        end
      )
    end)
  end)

  it("configures diffview's default and merge-tool layouts", function()
    -- Arrange
    local setup_spy, setup_data = helpers.spy()
    package.loaded.diffview = { setup = setup_spy }

    -- Act
    by_name("sindrets/diffview.nvim").config()

    -- Assert
    assert.equals(
      "diff2_horizontal",
      setup_data.last_call[1].view.default.layout
    )
    assert.equals(
      "diff3_horizontal",
      setup_data.last_call[1].view.merge_tool.layout
    )
  end)

  it(
    "configures neogit with <cr> restored to Toggle and diffview integration",
    function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      package.loaded.neogit = { setup = setup_spy }

      -- Act
      by_name("NeogitOrg/neogit").config()

      -- Assert
      local opts = setup_data.last_call[1]
      assert.equals("Toggle", opts.mappings.status["<cr>"])
      assert.is_true(opts.integrations.diffview)
      assert.is_false(opts.sections.unstaged.folded)
    end
  )
end)
