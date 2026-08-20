-- tests/yoda/plugins/difftool_spec.lua
local helpers = require("tests.helpers")

describe("plugins.difftool", function()
  local spec

  --- vim.cmd needs both call forms here: vim.cmd.packadd(name) and
  --- vim.cmd("DiffTool ..."). Replacing it wholesale with a plain spy
  --- function would break the .packadd sub-key form, so this stub supports
  --- both while recording every call.
  local function stub_vim_cmd()
    local calls = {}
    local mock = setmetatable({
      packadd = function(name)
        table.insert(calls, { "packadd", name })
      end,
    }, {
      __call = function(_, cmdstr)
        table.insert(calls, { "cmd", cmdstr })
      end,
    })
    vim.cmd = mock
    return calls
  end

  before_each(function()
    package.loaded["yoda.plugins.difftool"] = nil
    spec = require("yoda.plugins.difftool")
    pcall(vim.api.nvim_del_user_command, "DiffTool")
  end)

  after_each(function()
    pcall(vim.api.nvim_del_user_command, "DiffTool")
  end)

  it(
    "declares the built-in difftool as a virtual, cmd-triggered package",
    function()
      -- Assert
      assert.equals("nvim.difftool", spec[1])
      assert.is_true(spec.virtual)
      assert.equals("DiffTool", spec.cmd)
    end
  )

  it(
    "registers a DiffTool command that packadds and forwards its args",
    function()
      -- Arrange
      local original_vim_cmd = vim.cmd
      spec.init()
      local calls = stub_vim_cmd()

      -- Act: nvim_exec2 dispatches through the Ex-command layer, independent
      -- of whatever the Lua-level vim.cmd global currently points to, so the
      -- registered callback still runs and sees our stub inside its own body.
      vim.api.nvim_exec2("DiffTool a.txt b.txt", {})

      -- Assert
      assert.same({ "packadd", "nvim.difftool" }, calls[1])
      assert.same({ "cmd", "DiffTool a.txt b.txt" }, calls[2])

      vim.cmd = original_vim_cmd
    end
  )
end)
