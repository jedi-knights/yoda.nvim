-- tests/unit/messages_float_spec.lua
-- Tests for the floating messages window utility.

local messages_float = require("yoda.messages_float")

describe("messages_float", function()
  after_each(function()
    -- Close any floating windows we opened
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative and cfg.relative ~= "" then
        vim.api.nvim_win_close(win, true)
      end
    end
  end)

  it("opens a floating window with message content", function()
    -- Generate a message so :messages has output
    vim.api.nvim_echo({ { "test-message-for-float" } }, true, {})

    messages_float.show()

    -- Find the floating window
    local float_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative and cfg.relative ~= "" then
        float_win = win
        break
      end
    end

    assert.is_not_nil(float_win, "Expected a floating window to be opened")
    local buf = vim.api.nvim_win_get_buf(float_win)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(lines, "\n")
    assert.is_truthy(content:find("test%-message%-for%-float"), "Expected message content in buffer")
  end)

  it("sets the buffer as non-modifiable", function()
    vim.api.nvim_echo({ { "readonly-test" } }, true, {})

    messages_float.show()

    local float_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative and cfg.relative ~= "" then
        float_win = win
        break
      end
    end

    assert.is_not_nil(float_win)
    local buf = vim.api.nvim_win_get_buf(float_win)
    assert.is_false(vim.bo[buf].modifiable)
  end)

  it("sets q keymap to close the window", function()
    vim.api.nvim_echo({ { "close-test" } }, true, {})

    messages_float.show()

    local float_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative and cfg.relative ~= "" then
        float_win = win
        break
      end
    end

    assert.is_not_nil(float_win)
    local buf = vim.api.nvim_win_get_buf(float_win)
    local keymaps = vim.api.nvim_buf_get_keymap(buf, "n")
    local has_q = false
    for _, km in ipairs(keymaps) do
      if km.lhs == "q" then
        has_q = true
        break
      end
    end
    assert.is_true(has_q, "Expected 'q' keymap on the buffer")
  end)

  it("notifies when there are no messages", function()
    -- Clear messages first
    vim.cmd("messages clear")

    local notified = false
    local original_notify = vim.notify
    vim.notify = function(msg, _)
      if msg:find("No messages") then
        notified = true
      end
    end

    messages_float.show()

    vim.notify = original_notify
    assert.is_true(notified, "Expected notification when no messages")
  end)
end)
