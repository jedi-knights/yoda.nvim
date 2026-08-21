-- tests/yoda/extras/lang/vbnet_spec.lua
local helpers = require("tests.helpers")
local registry = require("yoda.core.lsp_registry")
local dap_registry = require("yoda.core.dap_registry")

describe("extras.lang.vbnet", function()
  local specs

  local function by_name(plugin)
    for _, spec in ipairs(specs) do
      if spec[1] == plugin then
        return spec
      end
    end
    return nil
  end

  before_each(function()
    registry._reset()
    dap_registry._reset()
    package.loaded["yoda.extras.lang.vbnet"] = nil
    specs = require("yoda.extras.lang.vbnet")
  end)

  after_each(function()
    registry._reset()
    dap_registry._reset()
  end)

  it(
    "registers its LSP servers -- no neotest adapter exists for VB.NET",
    function()
      -- Assert
      assert.same({ "omnisharp" }, registry.servers())
    end
  )

  it("registers its debug adapters", function()
    -- Assert
    assert.same({ "netcoredbg" }, registry.dap_adapters())
  end)

  it("ships no plugin specs it cannot back with a real integration", function()
    -- Assert: inventing a neotest or DAP entry here would surface a
    -- broken test runner rather than an honest absence.
    for _, spec in ipairs(specs) do
      assert.is_truthy(
        spec.optional,
        "only optional fragments belong in an LSP-only extra: "
          .. tostring(spec[1])
      )
    end
  end)

  describe("nvim-dap init()", function()
    local dap_spec

    before_each(function()
      dap_spec = by_name("mfussenegger/nvim-dap")
    end)

    it("registers a dap configurator", function()
      -- Act
      dap_spec.init()

      -- Assert
      assert.equals(1, #dap_registry.configurators())
    end)

    it("no-ops when netcoredbg is not installed", function()
      -- Arrange
      local restore = helpers.mock(vim.fn, "executable", function()
        return 0
      end)
      dap_spec.init()
      local fake_dap = { adapters = {}, configurations = {} }

      -- Act
      dap_registry.apply(fake_dap)

      -- Assert
      assert.is_nil(fake_dap.adapters.coreclr)
      assert.is_nil(fake_dap.configurations.vb)

      restore()
    end)

    it(
      "wires coreclr adapter and vb configuration when installed on an empty dap",
      function()
        -- Arrange
        local restore = helpers.mock(vim.fn, "executable", function()
          return 1
        end)
        dap_spec.init()
        local fake_dap = { adapters = {}, configurations = {} }

        -- Act
        dap_registry.apply(fake_dap)

        -- Assert
        assert.equals("executable", fake_dap.adapters.coreclr.type)
        assert.matches("netcoredbg$", fake_dap.adapters.coreclr.command)
        assert.same({ "--interpreter=vscode" }, fake_dap.adapters.coreclr.args)
        assert.equals(1, #fake_dap.configurations.vb)
        assert.equals("coreclr", fake_dap.configurations.vb[1].type)
        assert.equals("Launch - netcoredbg", fake_dap.configurations.vb[1].name)

        restore()
      end
    )

    it(
      "does not touch cs configuration -- that is csharp's responsibility",
      function()
        -- Arrange
        local restore = helpers.mock(vim.fn, "executable", function()
          return 1
        end)
        dap_spec.init()
        local fake_dap = { adapters = {}, configurations = {} }

        -- Act
        dap_registry.apply(fake_dap)

        -- Assert
        assert.is_nil(fake_dap.configurations.cs)

        restore()
      end
    )

    it(
      "preserves an existing coreclr adapter -- the whole point of the `or` guard",
      function()
        -- Arrange: simulate lang.csharp having already configured coreclr.
        local restore = helpers.mock(vim.fn, "executable", function()
          return 1
        end)
        dap_spec.init()
        local existing_adapter = {
          type = "executable",
          command = "/custom/path/netcoredbg",
          args = { "--custom-flag" },
        }
        local fake_dap = {
          adapters = { coreclr = existing_adapter },
          configurations = {},
        }

        -- Act
        dap_registry.apply(fake_dap)

        -- Assert: same table reference, not overwritten with a fresh one.
        assert.equals(existing_adapter, fake_dap.adapters.coreclr)

        restore()
      end
    )

    it("preserves an existing vb configuration list", function()
      -- Arrange
      local restore = helpers.mock(vim.fn, "executable", function()
        return 1
      end)
      dap_spec.init()
      local existing_configs = { { type = "coreclr", name = "user override" } }
      local fake_dap = {
        adapters = {},
        configurations = { vb = existing_configs },
      }

      -- Act
      dap_registry.apply(fake_dap)

      -- Assert
      assert.equals(existing_configs, fake_dap.configurations.vb)

      restore()
    end)

    it("program() prompts for the dll path with a Debug default", function()
      -- Arrange
      local restore_exec = helpers.mock(vim.fn, "executable", function()
        return 1
      end)
      local restore_cwd = helpers.mock(vim.fn, "getcwd", function()
        return "/proj/vbnet-app"
      end)
      local captured
      local restore_input = helpers.mock(
        vim.fn,
        "input",
        function(prompt, default, completion)
          captured = {
            prompt = prompt,
            default = default,
            completion = completion,
          }
          return "/proj/vbnet-app/bin/Debug/app.dll"
        end
      )
      dap_spec.init()
      local fake_dap = { adapters = {}, configurations = {} }
      dap_registry.apply(fake_dap)

      -- Act
      local result = fake_dap.configurations.vb[1].program()

      -- Assert
      assert.equals("/proj/vbnet-app/bin/Debug/app.dll", result)
      assert.equals("Path to dll: ", captured.prompt)
      assert.equals("/proj/vbnet-app/bin/Debug/", captured.default)
      assert.equals("file", captured.completion)

      restore_input()
      restore_cwd()
      restore_exec()
    end)
  end)
end)
