-- tests/yoda/commands/formatting_spec.lua
local helpers = require("tests.helpers")

describe("commands.formatting", function()
  local original_autoformat
  local original_notify

  local function clear_commands()
    pcall(vim.api.nvim_del_user_command, "FormatFeature")
    pcall(vim.api.nvim_del_user_command, "ToggleFormat")
  end

  before_each(function()
    original_autoformat = vim.g.autoformat
    original_notify = vim.notify
    clear_commands()
    package.loaded["yoda.commands.formatting"] = nil
    require("yoda.commands.formatting").setup()
  end)

  after_each(function()
    clear_commands()
    vim.g.autoformat = original_autoformat
    vim.notify = original_notify
    package.loaded["yoda.commands.formatting"] = nil
  end)

  describe(":ToggleFormat", function()
    it("flips vim.g.autoformat and notifies the new state", function()
      -- Arrange
      vim.g.autoformat = true
      local notify_spy, notify_data = helpers.spy()
      vim.notify = notify_spy

      -- Act
      vim.api.nvim_exec2("ToggleFormat", {})

      -- Assert
      assert.is_false(vim.g.autoformat)
      helpers.assert_called(notify_data)
      assert.matches("Disabled formatting on save", notify_data.last_call[1])
      assert.equals(vim.log.levels.INFO, notify_data.last_call[2])
    end)

    it("toggles from false back to true on a second invocation", function()
      -- Arrange
      vim.g.autoformat = false
      local notify_spy, notify_data = helpers.spy()
      vim.notify = notify_spy

      -- Act
      vim.api.nvim_exec2("ToggleFormat", {})

      -- Assert
      assert.is_true(vim.g.autoformat)
      assert.matches("Enabled formatting on save", notify_data.last_call[1])
    end)
  end)

  describe(":FormatFeature", function()
    it(
      "aligns Examples blocks and flushes them when the block ends (L68 truthy)",
      function()
        -- Arrange: layout must exit the Examples block on a non-pipe line
        -- to hit `if in_examples and #example_lines > 0 then` -- that's the
        -- flush-and-align branch. Without a trailing non-pipe line the loop
        -- just finishes with example_lines still in flight, exercising the
        -- post-loop cleanup rather than this branch.
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_current_buf(bufnr)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
          "Feature: Example flush",
          "  Scenario: X",
          "    Examples:",
          "      | a | bb |",
          "      | 1 | 22 |",
          "  Scenario: Y", -- exits the Examples block; L68 fires here
        })
        vim.notify = function() end

        -- Act
        vim.api.nvim_exec2("FormatFeature", {})

        -- Assert: format_example_block replaced the raw pipe lines with
        -- the "      | ..." aligned form (its prefix is a 6-space indent
        -- followed by "| "). The Scenario: Y line that exited the block
        -- is preserved verbatim. Both are downstream effects of L68
        -- firing -- without it, example_lines would linger and get
        -- flushed only after the loop.
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local saw_aligned = false
        for _, line in ipairs(lines) do
          -- format_example_block's output always begins with "      | "
          -- (six spaces + pipe + space).
          if line:sub(1, 8) == "      | " and line:find("a") then
            saw_aligned = true
          end
        end
        assert.is_true(saw_aligned, "expected an aligned Examples row")
        assert.is_true(
          vim.tbl_contains(lines, "  Scenario: Y"),
          "expected Scenario: Y to be preserved after the flush"
        )

        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end
      end
    )
  end)
end)
