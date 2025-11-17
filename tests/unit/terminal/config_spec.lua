-- Tests for terminal/config.lua
local config = require("yoda-terminal.config")

describe("terminal.config", function()
  -- Save originals
  local original_notify = vim.notify

  after_each(function()
    vim.notify = original_notify
  end)

  describe("DEFAULTS", function()
    it("has correct default values", function()
      assert.equals(0.9, config.DEFAULTS.WIDTH)
      assert.equals(0.85, config.DEFAULTS.HEIGHT)
      assert.equals("rounded", config.DEFAULTS.BORDER)
      assert.equals("center", config.DEFAULTS.TITLE_POS)
    end)
  end)

  describe("make_win_opts()", function()
    it("creates window options with title", function()
      local opts = config.make_win_opts("Test Terminal")

      assert.equals("editor", opts.relative)
      assert.equals("float", opts.position)
      assert.equals(0.9, opts.width)
      assert.equals(0.85, opts.height)
      assert.equals("rounded", opts.border)
      assert.equals("Test Terminal", opts.title)
      assert.equals("center", opts.title_pos)
    end)

    it("applies width override", function()
      local opts = config.make_win_opts("Test", { width = 0.5 })
      assert.equals(0.5, opts.width)
      assert.equals(0.85, opts.height) -- Default
    end)

    it("applies height override", function()
      local opts = config.make_win_opts("Test", { height = 0.7 })
      assert.equals(0.9, opts.width) -- Default
      assert.equals(0.7, opts.height)
    end)

    it("applies border override", function()
      local opts = config.make_win_opts("Test", { border = "single" })
      assert.equals("single", opts.border)
    end)

    it("applies title_pos override", function()
      local opts = config.make_win_opts("Test", { title_pos = "left" })
      assert.equals("left", opts.title_pos)
    end)

    it("handles nil overrides", function()
      local opts = config.make_win_opts("Test", nil)
      assert.equals(0.9, opts.width)
      assert.equals(0.85, opts.height)
    end)

    it("validates title is a string", function()
      local notified = false
      vim.notify = function(msg, level)
        if msg:match("must be a string") then
          notified = true
        end
      end

      local opts = config.make_win_opts(123)
      assert.is_true(notified)
      assert.equals(" Terminal ", opts.title) -- Fallback
    end)

    it("handles empty string title", function()
      local opts = config.make_win_opts("")
      assert.equals(" Terminal ", opts.title) -- Fallback
    end)

    it("handles nil title with notification", function()
      local notified = false
      vim.notify = function()
        notified = true
      end

      config.make_win_opts(nil)
      assert.is_true(notified)
    end)

    it("applies all overrides at once", function()
      local opts = config.make_win_opts("Custom", {
        width = 0.8,
        height = 0.6,
        border = "double",
        title_pos = "right",
      })

      assert.equals(0.8, opts.width)
      assert.equals(0.6, opts.height)
      assert.equals("double", opts.border)
      assert.equals("right", opts.title_pos)
      assert.equals("Custom", opts.title)
    end)
  end)

  describe("make_config()", function()
    it("creates complete terminal configuration", function()
      local cmd = { "bash", "-i" }
      local cfg = config.make_config(cmd, "My Terminal")

      assert.same(cmd, cfg.cmd)
      assert.equals("My Terminal", cfg.win.title)
      assert.is_table(cfg.win)
    end)

    it("validates cmd is a table", function()
      local notified = false
      vim.notify = function(msg, level)
        if msg:match("cmd must be a table") then
          notified = true
        end
      end

      local cfg = config.make_config("not a table", "Title")
      assert.is_true(notified)
      -- Should fallback to shell
      assert.is_table(cfg.cmd)
    end)

    it("uses vim.o.shell as fallback", function()
      local original_shell = vim.o.shell
      vim.o.shell = "/bin/test-shell"

      vim.notify = function() end -- Suppress notification

      local cfg = config.make_config("invalid", "Title")
      assert.same({ "/bin/test-shell" }, cfg.cmd)

      vim.o.shell = original_shell
    end)

    it("passes title to make_win_opts", function()
      local cfg = config.make_config({ "sh" }, "Custom Title")
      assert.equals("Custom Title", cfg.win.title)
    end)

    it("returns minimal config with cmd and win", function()
      local cfg = config.make_config({ "sh" }, "Title")
      assert.is_table(cfg.cmd)
      assert.is_table(cfg.win)
      assert.equals("Title", cfg.win.title)
    end)

    it("passes custom on_exit", function()
      local on_exit_fn = function() end
      local cfg = config.make_config({ "sh" }, "Title", { on_exit = on_exit_fn })
      assert.equals(on_exit_fn, cfg.on_exit)
    end)

    it("does not set on_open by default", function()
      local cfg = config.make_config({ "sh" }, "Title")
      assert.is_nil(cfg.on_open)
    end)

    it("passes window options through", function()
      local cfg = config.make_config({ "sh" }, "Title", {
        win = { width = 0.5, border = "double" },
      })

      assert.equals(0.5, cfg.win.width)
      assert.equals("double", cfg.win.border)
    end)
  end)
end)
