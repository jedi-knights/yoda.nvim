-- tests/yoda/plugins/undotree_spec.lua

describe("plugins.undotree", function()
  local spec

  --- Supports both vim.cmd.packadd(name) and vim.cmd("Undotree") without
  --- breaking the sub-key form (see difftool_spec.lua for the same need).
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
    package.loaded["yoda.plugins.undotree"] = nil
    spec = require("yoda.plugins.undotree")
  end)

  it(
    "declares the built-in undotree as a virtual package bound to <leader>u",
    function()
      -- Assert
      assert.equals("nvim.undotree", spec[1])
      assert.is_true(spec.virtual)
      assert.equals("<leader>u", spec.keys[1][1])
      assert.equals("Toggle undotree", spec.keys[1].desc)
    end
  )

  it("packadds the built-in package before opening it", function()
    -- Arrange
    local original_vim_cmd = vim.cmd
    local calls = stub_vim_cmd()

    -- Act
    spec.keys[1][2]()

    -- Assert
    assert.same({ "packadd", "nvim.undotree" }, calls[1])
    assert.same({ "cmd", "Undotree" }, calls[2])

    vim.cmd = original_vim_cmd
  end)
end)
