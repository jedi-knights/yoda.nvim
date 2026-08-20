-- tests/yoda/keymaps/rust_spec.lua
local helpers = require("tests.helpers")

describe("keymaps.rust", function()
  local buf
  local notify_spy_fn, notify_spy_data
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

  --- Stubs a `vim.cmd.<name>` sub-command directly (vim.cmd's __newindex
  --- falls through to a plain rawset, so this doesn't disturb any other
  --- vim.cmd.* magic) rather than replacing the whole vim.cmd callable.
  local function stub_cmd_field(name, fn)
    vim.cmd[name] = fn
    return function()
      vim.cmd[name] = nil
    end
  end

  before_each(function()
    package.loaded["yoda.keymaps.rust"] = nil
    notify_spy_fn, notify_spy_data = helpers.spy()
    package.loaded["yoda-adapters.notification"] = { notify = notify_spy_fn }
    require("yoda.keymaps.rust")

    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "/tmp/yoda_rust_spec_" .. buf .. ".rs")
    vim.api.nvim_set_current_buf(buf)

    local original_eventignore = vim.o.eventignore
    vim.o.eventignore = ""
    vim.bo[buf].filetype = "rust"
    vim.o.eventignore = original_eventignore

    cmd_spy_fn, cmd_spy_data = helpers.spy()
    original_vim_cmd = vim.cmd
  end)

  after_each(function()
    vim.cmd = original_vim_cmd
    package.loaded["yoda-adapters.notification"] = nil
    package.loaded["overseer"] = nil
    package.loaded["neotest"] = nil
    package.loaded["trouble"] = nil
    if buf and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  describe("<leader>rr (cargo run)", function()
    it("shells out to cargo run when overseer is unavailable", function()
      -- Arrange
      vim.cmd = cmd_spy_fn

      -- Act
      get_callback("Rust: Cargo run")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "Overseer not available. Running cargo run directly...",
        "warn"
      )
      helpers.assert_called_with(cmd_spy_data, "!cargo run")
    end)

    it("runs the cargo run template when overseer is available", function()
      -- Arrange
      local run_template_spy, run_template_data = helpers.spy()
      package.loaded["overseer"] = { run_template = run_template_spy }

      -- Act
      get_callback("Rust: Cargo run")()

      -- Assert
      helpers.assert_called_with(run_template_data, { name = "cargo run" })
      helpers.assert_not_called(notify_spy_data)
    end)
  end)

  describe("<leader>rb (cargo build)", function()
    it("shells out to cargo build when overseer is unavailable", function()
      -- Arrange
      vim.cmd = cmd_spy_fn

      -- Act
      get_callback("Rust: Cargo build")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "Overseer not available. Running cargo build directly...",
        "warn"
      )
      helpers.assert_called_with(cmd_spy_data, "!cargo build")
    end)

    it("runs the cargo build template when overseer is available", function()
      -- Arrange
      local run_template_spy, run_template_data = helpers.spy()
      package.loaded["overseer"] = { run_template = run_template_spy }

      -- Act
      get_callback("Rust: Cargo build")()

      -- Assert
      helpers.assert_called_with(run_template_data, { name = "cargo build" })
    end)
  end)

  for _, desc in ipairs({ "Rust: Test nearest", "Rust: Test file" }) do
    it(desc .. " notifies when neotest is unavailable", function()
      -- Act
      get_callback(desc)()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "Neotest not available. Install via :Lazy sync",
        "error"
      )
    end)

    it(desc .. " runs neotest when available", function()
      -- Arrange
      local run_spy, run_data = helpers.spy()
      package.loaded["neotest"] = { run = { run = run_spy } }

      -- Act
      get_callback(desc)()

      -- Assert
      helpers.assert_called(run_data, 1)
    end)
  end

  it("<leader>rd starts rustaceanvim debuggables", function()
    -- Arrange
    local spy_fn, spy_data = helpers.spy()
    local restore = stub_cmd_field("RustLsp", spy_fn)

    -- Act
    get_callback("Rust: Start debug")()

    -- Assert
    helpers.assert_called_with(spy_data, "debuggables")

    restore()
  end)

  describe("<leader>rh (toggle inlay hints)", function()
    local original_enable, original_is_enabled

    before_each(function()
      original_enable = vim.lsp.inlay_hint.enable
      original_is_enabled = vim.lsp.inlay_hint.is_enabled
    end)

    after_each(function()
      vim.lsp.inlay_hint.enable = original_enable
      vim.lsp.inlay_hint.is_enabled = original_is_enabled
    end)

    it("enables hints when currently disabled", function()
      -- Arrange
      vim.lsp.inlay_hint.is_enabled = function()
        return false
      end
      local enable_spy, enable_data = helpers.spy()
      vim.lsp.inlay_hint.enable = enable_spy

      -- Act
      get_callback("Rust: Toggle inlay hints")()

      -- Assert
      helpers.assert_called_with(enable_data, true)
    end)
  end)

  describe("<leader>re (open diagnostics)", function()
    it(
      "falls back to the diagnostic loclist when trouble is unavailable",
      function()
        -- Arrange
        local setloclist_spy, setloclist_data = helpers.spy()
        local original_setloclist = vim.diagnostic.setloclist
        vim.diagnostic.setloclist = setloclist_spy
        vim.cmd = cmd_spy_fn

        -- Act
        get_callback("Rust: Open diagnostics")()

        -- Assert
        helpers.assert_called(setloclist_data, 1)
        helpers.assert_not_called(cmd_spy_data)

        vim.diagnostic.setloclist = original_setloclist
      end
    )

    it("opens Trouble when available", function()
      -- Arrange
      package.loaded["trouble"] = {}
      vim.cmd = cmd_spy_fn

      -- Act
      get_callback("Rust: Open diagnostics")()

      -- Assert
      helpers.assert_called_with(
        cmd_spy_data,
        "Trouble diagnostics toggle filter.buf=0"
      )
    end)
  end)

  describe("<leader>ro (toggle outline)", function()
    after_each(function()
      pcall(vim.api.nvim_del_user_command, "AerialToggle")
    end)

    it("notifies when aerial is unavailable", function()
      -- Act
      get_callback("Rust: Toggle outline")()

      -- Assert
      helpers.assert_called_with(
        notify_spy_data,
        "Aerial not available. Install via :Lazy sync",
        "error"
      )
    end)

    it("does not notify when AerialToggle exists", function()
      -- Arrange
      vim.api.nvim_create_user_command("AerialToggle", function() end, {})

      -- Act
      get_callback("Rust: Toggle outline")()

      -- Assert
      helpers.assert_not_called(notify_spy_data)
    end)
  end)

  for _, case in ipairs({
    { desc = "Rust: Code actions", arg = "codeAction" },
    { desc = "Rust: Expand macro", arg = "expandMacro" },
    { desc = "Rust: Go to parent module", arg = "parentModule" },
    { desc = "Rust: Join lines", arg = "joinLines" },
  }) do
    it(case.desc .. " delegates to RustLsp " .. case.arg, function()
      -- Arrange
      local spy_fn, spy_data = helpers.spy()
      local restore = stub_cmd_field("RustLsp", spy_fn)

      -- Act
      get_callback(case.desc)()

      -- Assert
      helpers.assert_called_with(spy_data, case.arg)

      restore()
    end)
  end
end)
