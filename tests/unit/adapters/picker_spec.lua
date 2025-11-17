-- Tests for adapters/picker.lua
local picker = require("yoda-adapters.picker")

describe("adapters.picker", function()
  -- Save originals
  local original_ui_select = vim.ui.select
  local original_notify = vim.notify
  local original_yoda_backend = vim.g.yoda_picker_backend

  -- Reset before each test
  before_each(function()
    picker.reset_backend()
    vim.g.yoda_picker_backend = nil
    package.loaded["snacks"] = nil
    package.loaded["telescope"] = nil
  end)

  -- Restore after each test
  after_each(function()
    vim.ui.select = original_ui_select
    vim.notify = original_notify
    vim.g.yoda_picker_backend = original_yoda_backend
    picker.reset_backend()
    package.loaded["snacks"] = nil
    package.loaded["telescope"] = nil
  end)

  describe("detect_backend()", function()
    it("prefers user-configured backend", function()
      vim.g.yoda_picker_backend = "native"

      local backend = picker.get_backend()
      assert.equals("native", backend)
    end)

    it("detects snacks when available", function()
      package.loaded["snacks"] = {
        picker = {
          select = function() end,
        },
      }

      local backend = picker.get_backend()
      assert.equals("snacks", backend)
    end)

    it("falls back to telescope when snacks not available", function()
      package.loaded["telescope"] = {}

      local backend = picker.get_backend()
      assert.equals("telescope", backend)
    end)

    it("falls back to native when no plugins available", function()
      package.loaded["snacks"] = nil
      package.loaded["telescope"] = nil

      local backend = picker.get_backend()
      assert.equals("native", backend)
    end)

    it("caches backend detection (singleton)", function()
      package.loaded["snacks"] = {
        picker = { select = function() end },
      }

      local backend1 = picker.get_backend()

      -- Remove snacks
      package.loaded["snacks"] = nil

      -- Should still return snacks (cached)
      local backend2 = picker.get_backend()
      assert.equals(backend1, backend2)
      assert.equals("snacks", backend2)
    end)
  end)

  describe("set_backend()", function()
    it("sets backend to snacks", function()
      picker.set_backend("snacks")
      assert.equals("snacks", picker.get_backend())
    end)

    it("sets backend to telescope", function()
      picker.set_backend("telescope")
      assert.equals("telescope", picker.get_backend())
    end)

    it("sets backend to native", function()
      picker.set_backend("native")
      assert.equals("native", picker.get_backend())
    end)

    it("errors on unknown backend", function()
      local ok, err = pcall(function()
        picker.set_backend("unknown")
      end)
      assert.is_false(ok)
      assert.matches("Unknown backend", err)
    end)
  end)

  describe("reset_backend()", function()
    it("clears cached backend", function()
      picker.set_backend("native")
      assert.equals("native", picker.get_backend())

      picker.reset_backend()

      -- Should detect again
      package.loaded["snacks"] = {
        picker = { select = function() end },
      }

      assert.equals("snacks", picker.get_backend())
    end)
  end)

  describe("create()", function()
    it("returns snacks implementation", function()
      picker.set_backend("snacks")

      local impl = picker.create()
      assert.is_not_nil(impl)
      assert.is_function(impl.select)
    end)

    it("returns telescope implementation", function()
      picker.set_backend("telescope")

      local impl = picker.create()
      assert.is_not_nil(impl)
      assert.is_function(impl.select)
    end)

    it("returns native implementation", function()
      picker.set_backend("native")

      local impl = picker.create()
      assert.is_not_nil(impl)
      assert.is_function(impl.select)
    end)
  end)

  describe("select()", function()
    it("calls native vim.ui.select with correct parameters", function()
      picker.set_backend("native")

      local called = false
      local captured_items, captured_opts, captured_callback
      vim.ui.select = function(items, opts, callback)
        called = true
        captured_items = items
        captured_opts = opts
        captured_callback = callback
      end

      local items = { "a", "b", "c" }
      local callback_fn = function() end
      picker.select(items, { prompt = "Choose:" }, callback_fn)

      assert.is_true(called)
      assert.same(items, captured_items)
      assert.equals("Choose:", captured_opts.prompt)
      assert.equals(callback_fn, captured_callback)
    end)

    it("calls snacks picker with items", function()
      picker.set_backend("snacks")

      local called = false
      local captured_items
      package.loaded["snacks"] = {
        picker = {
          select = function(items, opts, callback)
            called = true
            captured_items = items
          end,
        },
      }

      picker.select({ "a", "b" }, {}, function() end)

      assert.is_true(called)
      assert.same({ "a", "b" }, captured_items)
    end)

    it("validates items is a table", function()
      local notified = false
      vim.notify = function(msg, level)
        if msg:match("items must be a table") then
          notified = true
        end
      end

      local callback_called = false
      picker.select("not a table", {}, function(selection)
        callback_called = true
        assert.is_nil(selection)
      end)

      assert.is_true(notified)
      assert.is_true(callback_called) -- Callback invoked with nil
    end)

    it("validates callback is a function", function()
      local notified = false
      vim.notify = function(msg, level)
        if msg:match("callback must be a function") then
          notified = true
        end
      end

      picker.select({ "a", "b" }, {}, "not a function")
      assert.is_true(notified)
    end)

    it("calls callback with selection", function()
      picker.set_backend("native")

      local selected = nil
      vim.ui.select = function(items, opts, callback)
        callback(items[2]) -- Select second item
      end

      picker.select({ "a", "b", "c" }, {}, function(item)
        selected = item
      end)

      assert.equals("b", selected)
    end)

    it("handles callback with nil selection (cancelled)", function()
      picker.set_backend("native")

      local callback_called = false
      local selected = "initial"
      vim.ui.select = function(items, opts, callback)
        callback(nil) -- User cancelled
      end

      picker.select({ "a", "b" }, {}, function(item)
        callback_called = true
        selected = item
      end)

      assert.is_true(callback_called)
      assert.is_nil(selected)
    end)

    it("passes options through to backend", function()
      picker.set_backend("native")

      local captured_opts
      vim.ui.select = function(items, opts, callback)
        captured_opts = opts
      end

      picker.select({ "a" }, {
        prompt = "Test",
        format_item = function(x)
          return x
        end,
      }, function() end)

      assert.equals("Test", captured_opts.prompt)
      assert.is_function(captured_opts.format_item)
    end)
  end)
end)
