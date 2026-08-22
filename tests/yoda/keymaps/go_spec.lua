-- tests/yoda/keymaps/go_spec.lua
-- Covers the "smart Enter after {" keymap for Go files, specifically the
-- vim.schedule cursor-positioning callback at go.lua:34.

describe("keymaps.go", function()
  local buf

  local function get_smart_enter_callback()
    -- The FileType/go autocmd registers the buffer-local <CR> keymap. Fire
    -- it manually so the keymap ends up on our buffer.
    local group_acs = vim.api.nvim_get_autocmds({
      group = "YodaGoKeymaps",
      event = "FileType",
    })
    assert.is_true(
      #group_acs >= 1,
      "YodaGoKeymaps FileType autocmd not registered"
    )
    group_acs[1].callback({ buf = buf })
    for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, "i")) do
      if km.desc == "Smart Enter with Go indentation" then
        return km.callback
      end
    end
    return nil
  end

  before_each(function()
    -- The keymaps/go module registers a FileType autocmd at require time.
    -- Idempotent registration is guaranteed by { clear = true } inside the
    -- augroup, so a fresh require gives a clean autocmd set.
    package.loaded["yoda.keymaps.go"] = nil
    require("yoda.keymaps.go")
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, buf)
    vim.bo[buf].filetype = "go"
  end)

  after_each(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    pcall(vim.api.nvim_del_augroup_by_name, "YodaGoKeymaps")
    package.loaded["yoda.keymaps.go"] = nil
  end)

  it(
    "smart-Enter after `{` schedules cursor positioning at end of new indent",
    function()
      -- Arrange: put a `func foo() { ` line in the buffer (with a trailing
      -- space so the cursor has a valid position after `{` in normal-mode
      -- semantics -- nvim_win_set_cursor clamps beyond-end positions).
      -- Stub vim.schedule to capture the deferred function so we can drive
      -- it deterministically; nvim_put's behavior in a headless scratch
      -- buffer is unreliable, so we don't depend on it creating a new line.
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "func foo() { " })
      vim.api.nvim_win_set_cursor(0, { 1, 12 }) -- col right after `{`
      local cb = get_smart_enter_callback()
      assert.is_function(cb, "smart-Enter callback not found on buffer")

      local captured_schedule_fn
      local original_schedule = vim.schedule
      vim.schedule = function(fn)
        captured_schedule_fn = fn
      end
      local set_cursor_calls = {}
      local original_set_cursor = vim.api.nvim_win_set_cursor
      vim.api.nvim_win_set_cursor = function(win, pos)
        table.insert(set_cursor_calls, { win = win, pos = pos })
      end

      -- Act: invoke the outer keymap callback. It should schedule the
      -- cursor-position update.
      cb()

      -- Assert: schedule was called with a function.
      vim.schedule = original_schedule
      assert.is_function(
        captured_schedule_fn,
        "the outer callback did not call vim.schedule"
      )

      -- Now invoke the scheduled function directly. It reads current cursor
      -- (mocked as `original_set_cursor` above did NOT set a new cursor --
      -- so this returns the ORIGINAL cursor from nvim_win_get_cursor).
      captured_schedule_fn()
      vim.api.nvim_win_set_cursor = original_set_cursor

      -- Assert: nvim_win_set_cursor was called with column == length of
      -- new_indent (4 spaces = 8 leading spaces? no -- the source computes
      -- new_indent = current_indent (empty on our test line) + 4 spaces = 4.
      -- So #new_indent = 4.
      assert.is_true(
        #set_cursor_calls >= 1,
        "expected nvim_win_set_cursor to be called from the scheduled fn"
      )
      local last = set_cursor_calls[#set_cursor_calls]
      assert.is_true(
        last.pos[2] == 4,
        "expected new cursor column 4, got " .. tostring(last.pos[2])
      )
    end
  )
end)
