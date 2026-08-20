-- tests/yoda/plugins/mini_pick_spec.lua
-- Validates mini.pick and mini.extra plugin specs are correctly defined,
-- and (below) exercises every config()/keys callback in mini.lua -- none
-- of them had ever actually been invoked.
local helpers = require("tests.helpers")

describe("mini.pick plugin spec", function()
  local specs

  before_each(function()
    specs = dofile(vim.fn.getcwd() .. "/lua/yoda/plugins/mini.lua")
  end)

  --- Find a spec entry by its plugin name (first element).
  local function find_spec(name)
    for _, spec in ipairs(specs) do
      if spec[1] == name then
        return spec
      end
    end
    return nil
  end

  it("includes mini.pick", function()
    local pick = find_spec("echasnovski/mini.pick")
    assert.is_not_nil(pick, "mini.pick spec not found in mini.lua")
  end)

  it("includes mini.extra", function()
    local extra = find_spec("echasnovski/mini.extra")
    assert.is_not_nil(extra, "mini.extra spec not found in mini.lua")
  end)

  it("mini.pick has event or keys for lazy loading", function()
    local pick = find_spec("echasnovski/mini.pick")
    assert.is_not_nil(pick, "mini.pick spec not found")
    local has_lazy_trigger = pick.event ~= nil
      or pick.keys ~= nil
      or pick.cmd ~= nil
    assert.is_true(
      has_lazy_trigger,
      "mini.pick should have a lazy-loading trigger (event, keys, or cmd)"
    )
  end)

  it("mini.pick depends on mini.extra", function()
    local pick = find_spec("echasnovski/mini.pick")
    assert.is_not_nil(pick, "mini.pick spec not found")
    assert.is_not_nil(
      pick.dependencies,
      "mini.pick should declare dependencies"
    )
    local has_extra = false
    for _, dep in ipairs(pick.dependencies) do
      local dep_name = type(dep) == "string" and dep or dep[1]
      if dep_name == "echasnovski/mini.extra" then
        has_extra = true
        break
      end
    end
    assert.is_true(has_extra, "mini.pick should depend on mini.extra")
  end)

  describe("keymaps", function()
    local expected_keys = {
      { key = "<leader><leader>", desc_pattern = "[Ff]ind [Ff]iles" },
      { key = "<leader>/", desc_pattern = "[Ll]ive [Gg]rep" },
      { key = "<leader>sh", desc_pattern = "[Hh]elp" },
      { key = "<leader>sk", desc_pattern = "[Kk]eymap" },
      { key = "<leader>s.", desc_pattern = "[Rr]ecent" },
      { key = "<leader>sd", desc_pattern = "[Dd]iagnostic" },
      { key = "<leader>sb", desc_pattern = "[Bb]uffer" },
    }

    it("defines all expected keymaps", function()
      local pick = find_spec("echasnovski/mini.pick")
      assert.is_not_nil(pick, "mini.pick spec not found")
      assert.is_not_nil(pick.keys, "mini.pick should have keys defined")

      for _, expected in ipairs(expected_keys) do
        local found = false
        for _, keydef in ipairs(pick.keys) do
          local k = type(keydef) == "table" and keydef[1] or keydef
          if k == expected.key then
            found = true
            break
          end
        end
        assert.is_true(
          found,
          "Expected keymap '" .. expected.key .. "' not found in mini.pick keys"
        )
      end
    end)
  end)

  --- Find a key entry's callback by its lhs.
  local function find_key_fn(pick_spec, lhs)
    for _, keydef in ipairs(pick_spec.keys) do
      if keydef[1] == lhs then
        return keydef[2]
      end
    end
    error("no key entry for " .. lhs)
  end

  describe("config() functions", function()
    after_each(function()
      package.loaded["mini.icons"] = nil
      package.loaded["mini.pick"] = nil
    end)

    it("mini.icons.setup() is invoked", function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      package.loaded["mini.icons"] = { setup = setup_spy }

      -- Act
      find_spec("echasnovski/mini.icons").config()

      -- Assert
      helpers.assert_called(setup_data, 1)
    end)

    it("mini.pick.setup() configures window border and move keys", function()
      -- Arrange
      local setup_spy, setup_data = helpers.spy()
      package.loaded["mini.pick"] = { setup = setup_spy }

      -- Act
      find_spec("echasnovski/mini.pick").config()

      -- Assert
      local opts = setup_data.last_call[1]
      assert.equals("<C-j>", opts.mappings.move_down)
      assert.equals("<C-k>", opts.mappings.move_up)
      assert.equals("rounded", opts.window.config.border)
    end)
  end)

  describe("keys callbacks", function()
    local pick

    before_each(function()
      pick = find_spec("echasnovski/mini.pick")
    end)

    after_each(function()
      package.loaded["mini.pick"] = nil
      package.loaded["mini.extra"] = nil
    end)

    it("<leader><leader> opens the file picker", function()
      -- Arrange
      local files_spy, files_data = helpers.spy()
      package.loaded["mini.pick"] = { builtin = { files = files_spy } }

      -- Act
      find_key_fn(pick, "<leader><leader>")()

      -- Assert
      helpers.assert_called(files_data, 1)
    end)

    it("<leader>/ opens live grep", function()
      -- Arrange
      local grep_spy, grep_data = helpers.spy()
      package.loaded["mini.pick"] = { builtin = { grep_live = grep_spy } }

      -- Act
      find_key_fn(pick, "<leader>/")()

      -- Assert
      helpers.assert_called(grep_data, 1)
    end)

    it("<leader>sh searches help", function()
      -- Arrange
      local help_spy, help_data = helpers.spy()
      package.loaded["mini.pick"] = { builtin = { help = help_spy } }

      -- Act
      find_key_fn(pick, "<leader>sh")()

      -- Assert
      helpers.assert_called(help_data, 1)
    end)

    it("<leader>sk searches keymaps via mini.extra", function()
      -- Arrange
      local keymaps_spy, keymaps_data = helpers.spy()
      package.loaded["mini.extra"] = { pickers = { keymaps = keymaps_spy } }

      -- Act
      find_key_fn(pick, "<leader>sk")()

      -- Assert
      helpers.assert_called(keymaps_data, 1)
    end)

    it("<leader>s. searches recent files via mini.extra", function()
      -- Arrange
      local oldfiles_spy, oldfiles_data = helpers.spy()
      package.loaded["mini.extra"] = { pickers = { oldfiles = oldfiles_spy } }

      -- Act
      find_key_fn(pick, "<leader>s.")()

      -- Assert
      helpers.assert_called(oldfiles_data, 1)
    end)

    it("<leader>sd searches diagnostics via mini.extra", function()
      -- Arrange
      local diagnostic_spy, diagnostic_data = helpers.spy()
      package.loaded["mini.extra"] =
        { pickers = { diagnostic = diagnostic_spy } }

      -- Act
      find_key_fn(pick, "<leader>sd")()

      -- Assert
      helpers.assert_called(diagnostic_data, 1)
    end)

    it("<leader>sb searches open buffers", function()
      -- Arrange
      local buffers_spy, buffers_data = helpers.spy()
      package.loaded["mini.pick"] = { builtin = { buffers = buffers_spy } }

      -- Act
      find_key_fn(pick, "<leader>sb")()

      -- Assert
      helpers.assert_called(buffers_data, 1)
    end)

    describe("<leader>sc (search git-changed files)", function()
      local original_systemlist

      before_each(function()
        original_systemlist = vim.fn.systemlist
      end)

      after_each(function()
        vim.fn.systemlist = original_systemlist
      end)

      it("combines diff and untracked files into one picker source", function()
        -- Arrange
        vim.fn.systemlist = function(cmd)
          if cmd:find("diff", 1, true) then
            return { "modified.lua" }
          end
          return { "untracked.lua" }
        end
        local start_spy, start_data = helpers.spy()
        package.loaded["mini.pick"] = { start = start_spy }

        -- Act
        find_key_fn(pick, "<leader>sc")()

        -- Assert
        helpers.assert_called(start_data, 1)
        local source = start_data.last_call[1].source
        assert.equals("Git Changed", source.name)
        assert.same({ "modified.lua", "untracked.lua" }, source.items)
      end)

      it("choosing an item opens it with fnameescape applied", function()
        -- Arrange
        vim.fn.systemlist = function()
          return {}
        end
        local start_spy, start_data = helpers.spy()
        package.loaded["mini.pick"] = { start = start_spy }
        find_key_fn(pick, "<leader>sc")()
        local choose = start_data.last_call[1].source.choose
        local cmd_spy, cmd_data = helpers.spy()
        local original_vim_cmd = vim.cmd
        vim.cmd = cmd_spy

        -- Act
        choose("some file.lua")

        -- Assert
        assert.equals("edit some\\ file.lua", cmd_data.last_call[1])

        vim.cmd = original_vim_cmd
      end)
    end)
  end)
end)
