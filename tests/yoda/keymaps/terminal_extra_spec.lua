-- tests/yoda/keymaps/terminal_extra_spec.lua
-- Behavioral coverage for keymaps/terminal.lua. Kept separate from the
-- existing terminal_spec.lua (which asserts on source text for the
-- <C-h/j/k/l> mappings) rather than folding into it, so that file's narrow
-- static-analysis scope isn't disturbed.
local helpers = require("tests.helpers")

describe("keymaps.terminal (behavior)", function()
  local function get_keymap(mode, desc)
    for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
      if km.desc == desc then
        return km
      end
    end
    error("no keymap registered with desc: " .. desc)
  end

  before_each(function()
    package.loaded["yoda.keymaps.terminal"] = nil
    require("yoda.keymaps.terminal")
  end)

  after_each(function()
    package.loaded["yoda-terminal"] = nil
    package.loaded["snacks.terminal"] = nil
  end)

  it("<leader>. opens yoda-terminal's floating terminal", function()
    -- Arrange
    local open_spy, open_data = helpers.spy()
    package.loaded["yoda-terminal"] = { open_floating = open_spy }

    -- Act
    get_keymap("n", "Terminal: Open floating terminal").callback()

    -- Assert
    helpers.assert_called(open_data, 1)
  end)

  it("<leader>Tt opens a floating zsh shell via snacks.terminal", function()
    -- Arrange
    local open_spy, open_data = helpers.spy()
    local close_spy, close_data = helpers.spy()
    package.loaded["snacks.terminal"] = { open = open_spy, close = close_spy }

    -- Act
    get_keymap("n", "Terminal: Floating shell").callback()

    -- Assert
    helpers.assert_called(open_data, 1)
    local opts = open_data.last_call[1]
    assert.equals("myterm", opts.id)
    assert.same({ "/bin/zsh" }, opts.cmd)

    -- Act: the terminal job's on_exit callback closes it by id
    opts.on_exit()

    -- Assert
    helpers.assert_called_with(close_data, "myterm")
  end)

  describe("terminal-mode window navigation", function()
    local original_vim_cmd

    before_each(function()
      original_vim_cmd = vim.cmd
    end)

    after_each(function()
      vim.cmd = original_vim_cmd
    end)

    for _, case in ipairs({
      { key = "<C-h>", dir = "h", desc = "Window: Move left from terminal" },
      { key = "<C-j>", dir = "j", desc = "Window: Move down from terminal" },
      { key = "<C-k>", dir = "k", desc = "Window: Move up from terminal" },
      { key = "<C-l>", dir = "l", desc = "Window: Move right from terminal" },
    }) do
      it(case.key .. " stops insert then moves " .. case.dir, function()
        -- Arrange
        local cmd_spy, cmd_data = helpers.spy()
        vim.cmd = cmd_spy

        -- Act
        get_keymap("t", case.desc).callback()
        vim.wait(50, function()
          return cmd_data.call_count >= 2
        end)

        -- Assert
        assert.equals("stopinsert", cmd_data.calls[1][1])
        assert.equals("wincmd " .. case.dir, cmd_data.calls[2][1])
      end)
    end
  end)

  describe("<leader>Tr (Python REPL)", function()
    local original_filereadable

    before_each(function()
      original_filereadable = vim.fn.filereadable
    end)

    after_each(function()
      vim.fn.filereadable = original_filereadable
    end)

    it("uses the project venv's python when present", function()
      -- Arrange
      vim.fn.filereadable = function()
        return 1
      end
      local toggle_spy, toggle_data = helpers.spy()
      package.loaded["snacks.terminal"] = { toggle = toggle_spy }

      -- Act
      get_keymap("n", "Terminal: Python REPL").callback()

      -- Assert
      assert.matches("%.venv/bin/python3$", toggle_data.last_call[2].cmd[1])
    end)

    it("falls back to the system python3 when no venv is present", function()
      -- Arrange
      vim.fn.filereadable = function()
        return 0
      end
      local toggle_spy, toggle_data = helpers.spy()
      local close_spy = helpers.spy()
      package.loaded["snacks.terminal"] =
        { toggle = toggle_spy, close = close_spy }

      -- Act
      get_keymap("n", "Terminal: Python REPL").callback()

      -- Assert
      assert.equals("python", toggle_data.last_call[1])
      local opts = toggle_data.last_call[2]
      assert.is_not_nil(opts.cmd[1])

      -- Act: the terminal's on_exit closes the same "python" terminal
      opts.on_exit()
    end)
  end)
end)
