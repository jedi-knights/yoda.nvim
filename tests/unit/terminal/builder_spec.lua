-- Tests for terminal/builder.lua
local Builder = require("yoda-terminal.builder")

describe("terminal.builder", function()
  after_each(function()
    package.loaded["yoda.terminal.config"] = nil
    package.loaded["yoda.terminal.shell"] = nil
  end)

  describe("new()", function()
    it("creates builder instance", function()
      local builder = Builder:new()
      assert.is_not_nil(builder)
      assert.is_table(builder)
    end)

    it("has default values", function()
      local builder = Builder:new()
      assert.equals(" Terminal ", builder._title)
      assert.is_true(builder._start_insert)
      assert.is_true(builder._auto_insert)
      assert.same({}, builder._win)
    end)
  end)

  describe("with_command()", function()
    it("sets command as table", function()
      local builder = Builder:new():with_command({ "python", "-i" })
      assert.same({ "python", "-i" }, builder._cmd)
    end)

    it("converts string to table", function()
      local builder = Builder:new():with_command("bash")
      assert.same({ "bash" }, builder._cmd)
    end)

    it("returns self for chaining", function()
      local builder = Builder:new()
      local result = builder:with_command({ "sh" })
      assert.equals(builder, result)
    end)

    it("errors on invalid command type", function()
      local ok = pcall(function()
        Builder:new():with_command(123)
      end)
      assert.is_false(ok)
    end)
  end)

  describe("with_title()", function()
    it("sets title", function()
      local builder = Builder:new():with_title("Python REPL")
      assert.equals("Python REPL", builder._title)
    end)

    it("returns self for chaining", function()
      local builder = Builder:new()
      local result = builder:with_title("Test")
      assert.equals(builder, result)
    end)

    it("validates title is string", function()
      local ok = pcall(function()
        Builder:new():with_title(123)
      end)
      assert.is_false(ok)
    end)
  end)

  describe("with_window()", function()
    it("sets window options", function()
      local builder = Builder:new():with_window({ width = 0.8, border = "double" })
      assert.equals(0.8, builder._win.width)
      assert.equals("double", builder._win.border)
    end)

    it("returns self for chaining", function()
      local builder = Builder:new()
      local result = builder:with_window({})
      assert.equals(builder, result)
    end)

    it("validates window options is table", function()
      local ok = pcall(function()
        Builder:new():with_window("not a table")
      end)
      assert.is_false(ok)
    end)
  end)

  describe("with_env()", function()
    it("sets environment variables", function()
      local builder = Builder:new():with_env({ PATH = "/custom/path" })
      assert.equals("/custom/path", builder._env.PATH)
    end)

    it("returns self for chaining", function()
      local builder = Builder:new()
      local result = builder:with_env({})
      assert.equals(builder, result)
    end)

    it("validates env is table", function()
      local ok = pcall(function()
        Builder:new():with_env("not a table")
      end)
      assert.is_false(ok)
    end)
  end)

  describe("auto_insert()", function()
    it("enables auto insert", function()
      local builder = Builder:new():auto_insert(true)
      assert.is_true(builder._auto_insert)
    end)

    it("disables auto insert", function()
      local builder = Builder:new():auto_insert(false)
      assert.is_false(builder._auto_insert)
    end)

    it("returns self for chaining", function()
      local builder = Builder:new()
      local result = builder:auto_insert(true)
      assert.equals(builder, result)
    end)
  end)

  describe("start_insert()", function()
    it("enables start insert", function()
      local builder = Builder:new():start_insert(true)
      assert.is_true(builder._start_insert)
    end)

    it("disables start insert", function()
      local builder = Builder:new():start_insert(false)
      assert.is_false(builder._start_insert)
    end)

    it("returns self for chaining", function()
      local builder = Builder:new()
      local result = builder:start_insert(true)
      assert.equals(builder, result)
    end)
  end)

  describe("on_exit()", function()
    it("sets exit callback", function()
      local callback = function() end
      local builder = Builder:new():on_exit(callback)
      assert.equals(callback, builder._on_exit)
    end)

    it("returns self for chaining", function()
      local builder = Builder:new()
      local result = builder:on_exit(function() end)
      assert.equals(builder, result)
    end)

    it("validates callback is function", function()
      local ok = pcall(function()
        Builder:new():on_exit("not a function")
      end)
      assert.is_false(ok)
    end)
  end)

  describe("on_open()", function()
    it("sets open callback", function()
      local callback = function() end
      local builder = Builder:new():on_open(callback)
      assert.equals(callback, builder._on_open)
    end)

    it("returns self for chaining", function()
      local builder = Builder:new()
      local result = builder:on_open(function() end)
      assert.equals(builder, result)
    end)

    it("validates callback is function", function()
      local ok = pcall(function()
        Builder:new():on_open(123)
      end)
      assert.is_false(ok)
    end)
  end)

  describe("build()", function()
    it("builds simple configuration", function()
      package.loaded["yoda.terminal.config"] = {
        make_config = function(cmd, title, opts)
          return { cmd = cmd, title = title, opts = opts }
        end,
      }

      package.loaded["yoda.terminal.shell"] = {
        get_default = function()
          return "/bin/sh"
        end,
      }

      local config = Builder:new():build()
      assert.is_not_nil(config)
    end)

    it("uses provided command", function()
      local captured_cmd = nil

      package.loaded["yoda.terminal.config"] = {
        make_config = function(cmd, title, opts)
          captured_cmd = cmd
          return {}
        end,
      }

      Builder:new():with_command({ "python", "-i" }):build()
      assert.same({ "python", "-i" }, captured_cmd)
    end)

    it("uses default shell when no command specified", function()
      local captured_cmd = nil

      package.loaded["yoda.terminal.config"] = {
        make_config = function(cmd, title, opts)
          captured_cmd = cmd
          return {}
        end,
      }

      package.loaded["yoda.terminal.shell"] = {
        get_default = function()
          return "/bin/zsh"
        end,
      }

      Builder:new():build()
      assert.same({ "/bin/zsh", "-i" }, captured_cmd)
    end)

    it("passes title to config", function()
      local captured_title = nil

      package.loaded["yoda.terminal.config"] = {
        make_config = function(cmd, title, opts)
          captured_title = title
          return {}
        end,
      }

      package.loaded["yoda.terminal.shell"] = {
        get_default = function()
          return "/bin/sh"
        end,
      }

      Builder:new():with_title("Python REPL"):build()
      assert.equals("Python REPL", captured_title)
    end)

    it("passes all options to config", function()
      local captured_opts = nil

      package.loaded["yoda.terminal.config"] = {
        make_config = function(cmd, title, opts)
          captured_opts = opts
          return {}
        end,
      }

      package.loaded["yoda.terminal.shell"] = {
        get_default = function()
          return "/bin/sh"
        end,
      }

      Builder:new():with_window({ width = 0.5 }):with_env({ PATH = "/test" }):auto_insert(false):start_insert(false):build()

      assert.same({ width = 0.5 }, captured_opts.win)
      assert.same({ PATH = "/test" }, captured_opts.env)
      assert.is_false(captured_opts.auto_insert)
      assert.is_false(captured_opts.start_insert)
    end)

    it("supports full fluent chain", function()
      package.loaded["yoda.terminal.config"] = {
        make_config = function(cmd, title, opts)
          return { cmd = cmd, title = title }
        end,
      }

      local config = Builder:new()
        :with_command({ "node" })
        :with_title("Node REPL")
        :with_window({ width = 0.7, height = 0.6 })
        :with_env({ NODE_ENV = "development" })
        :auto_insert(true)
        :start_insert(true)
        :on_exit(function() end)
        :build()

      assert.is_not_nil(config)
    end)
  end)

  describe("open()", function()
    it("builds and opens terminal with snacks", function()
      local opened = false

      package.loaded["yoda.terminal.config"] = {
        make_win_opts = function(title, overrides)
          return { title = title }
        end,
      }

      package.loaded["yoda.terminal.shell"] = {
        get_default = function()
          return "/bin/sh"
        end,
      }

      package.loaded["snacks"] = {
        terminal = {
          open = function(cmd, cfg)
            opened = true
          end,
        },
      }

      Builder:new():open()
      assert.is_true(opened)
    end)
  end)
end)
