-- tests/yoda/keymaps/go_extra_spec.lua
-- Behavioral coverage for keymaps/go.lua. Kept separate from the existing
-- static-analysis-style keymaps_spec.lua conventions used elsewhere.
local helpers = require("tests.helpers")

describe("keymaps.go (behavior)", function()
  local buf
  local cmd_spy_fn, cmd_spy_data
  local original_vim_cmd

  local function get_callback(desc)
    for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
      if km.desc == desc then
        return km.callback
      end
    end
    error("no keymap registered with desc: " .. desc)
  end

  local function get_insert_callback(desc)
    for _, km in ipairs(vim.api.nvim_buf_get_keymap(buf, "i")) do
      if km.desc == desc then
        return km.callback
      end
    end
    error("no keymap registered with desc: " .. desc)
  end

  before_each(function()
    package.loaded["yoda.keymaps.go"] = nil
    require("yoda.keymaps.go")

    buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(buf, "/tmp/yoda_go_spec_" .. buf .. ".go")
    vim.api.nvim_set_current_buf(buf)

    local original_eventignore = vim.o.eventignore
    vim.o.eventignore = ""
    vim.bo[buf].filetype = "go"
    vim.o.eventignore = original_eventignore

    cmd_spy_fn, cmd_spy_data = helpers.spy()
    original_vim_cmd = vim.cmd
  end)

  after_each(function()
    vim.cmd = original_vim_cmd
    package.loaded["which-key"] = nil
    if buf and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  it("<leader>gf formats the buffer with gofmt", function()
    -- Arrange
    vim.cmd = cmd_spy_fn

    -- Act
    get_callback("Format Go file with gofmt")()

    -- Assert
    assert.equals("silent! %!gofmt", cmd_spy_data.last_call[1])
  end)

  it("<leader>gb builds the Go project", function()
    -- Arrange
    vim.cmd = cmd_spy_fn

    -- Act
    get_callback("Build Go project")()

    -- Assert
    assert.equals("!go build", cmd_spy_data.last_call[1])
  end)

  it("<leader>gr runs the current Go file", function()
    -- Arrange
    vim.cmd = cmd_spy_fn
    local original_expand = vim.fn.expand
    vim.fn.expand = function()
      return "main.go"
    end

    -- Act
    get_callback("Run current Go file")()

    -- Assert
    assert.equals("!go run main.go", cmd_spy_data.last_call[1])

    vim.fn.expand = original_expand
  end)

  it(
    "relabels the <leader>g which-key group to 'Go' for this buffer",
    function()
      -- Arrange
      local add_spy, add_data = helpers.spy()
      package.loaded["which-key"] = { add = add_spy }

      -- Act: which-key's require happens inside the FileType callback, so
      -- re-trigger it with the stub in place rather than reaching for a
      -- private closure.
      local original_eventignore = vim.o.eventignore
      vim.o.eventignore = ""
      vim.bo[buf].filetype = ""
      vim.bo[buf].filetype = "go"
      vim.o.eventignore = original_eventignore

      -- Assert
      helpers.assert_called_with(
        add_data,
        { { "<leader>g", group = "Go", buffer = buf } }
      )
    end
  )

  describe("smart <CR> in insert mode", function()
    it("indents the new line when the previous line opens a block", function()
      -- Arrange
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "func foo() {" })
      vim.api.nvim_win_set_cursor(0, { 1, 12 })
      -- nvim_put's cursor/insertion semantics depend on genuinely being in
      -- insert mode, not just on the buffer/window being current.
      vim.cmd("startinsert!")

      -- Act
      get_insert_callback("Smart Enter with Go indentation")()
      vim.cmd("stopinsert")

      -- Assert
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.equals(2, #lines)
      assert.equals("    ", lines[2])
    end)

    it("feeds a plain <CR> when the line does not open a block", function()
      -- Arrange
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "x := 1" })
      vim.api.nvim_win_set_cursor(0, { 1, 6 })
      local feedkeys_spy, feedkeys_data = helpers.spy()
      local original_feedkeys = vim.api.nvim_feedkeys
      vim.api.nvim_feedkeys = feedkeys_spy

      -- Act
      get_insert_callback("Smart Enter with Go indentation")()

      -- Assert
      helpers.assert_called(feedkeys_data, 1)

      vim.api.nvim_feedkeys = original_feedkeys
    end)
  end)
end)
