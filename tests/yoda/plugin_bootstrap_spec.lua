-- tests/yoda/plugin_bootstrap_spec.lua
-- Black-box tests for plugin/yoda.lua -- the bootstrap commands Neovim
-- auto-sources from the runtimepath. Loaded manually here via dofile since
-- plenary's test harness runs with --noplugin, so plugin/ is never
-- auto-sourced during a spec run.

describe("plugin/yoda.lua", function()
  local plugin_path = vim.fn.getcwd() .. "/plugin/yoda.lua"

  before_each(function()
    vim.g.loaded_yoda = nil
    pcall(vim.api.nvim_del_user_command, "Yoda")
    pcall(vim.api.nvim_del_user_command, "YodaExtras")
    pcall(vim.api.nvim_del_user_command, "YodaHealth")
    require("yoda.config")._reset()
    dofile(plugin_path)
  end)

  it("registers the :Yoda command", function()
    -- Arrange / Act
    local commands = vim.api.nvim_get_commands({})

    -- Assert
    assert.is_not_nil(commands.Yoda)
  end)

  it("registers the :YodaExtras command", function()
    -- Arrange / Act
    local commands = vim.api.nvim_get_commands({})

    -- Assert
    assert.is_not_nil(commands.YodaExtras)
  end)

  it("registers the :YodaHealth command", function()
    -- Arrange / Act
    local commands = vim.api.nvim_get_commands({})

    -- Assert
    assert.is_not_nil(commands.YodaHealth)
  end)

  it(":Yoda is callable without error before setup() has run", function()
    -- Arrange / Act / Assert
    local ok = pcall(function()
      vim.cmd("Yoda")
    end)
    assert.is_true(ok)
  end)

  it(":Yoda is callable without error after setup() has run", function()
    -- Arrange
    require("yoda").setup()

    -- Act / Assert
    local ok = pcall(function()
      vim.cmd("Yoda")
    end)
    assert.is_true(ok)
  end)

  it(":YodaExtras is callable without error", function()
    -- Arrange / Act / Assert
    local ok = pcall(function()
      vim.cmd("YodaExtras")
    end)
    assert.is_true(ok)
  end)

  it("guards against double-loading via vim.g.loaded_yoda", function()
    -- Arrange: sourcing a second time should be a harmless no-op, not error
    -- Act / Assert
    local ok = pcall(dofile, plugin_path)
    assert.is_true(ok)
    assert.is_true(vim.g.loaded_yoda)
  end)
end)
