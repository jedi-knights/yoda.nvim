-- Tests for picker_handler.lua
local PickerHandler = require("yoda.picker_handler")

describe("picker_handler", function()
  -- Mock config_loader
  local mock_config_loader
  local original_config_loader

  before_each(function()
    -- Save original
    original_config_loader = package.loaded["yoda.config_loader"]

    -- Create mock
    mock_config_loader = {
      load_marker = function(path)
        return {
          environment = "qa",
          region = "auto",
          markers = "bdd",
          open_allure = false,
        }
      end,
      save_marker = function(path, env, region, markers, allure)
        -- Mock save
      end,
      load_pytest_markers = function(path)
        return { "bdd", "unit", "smoke" }
      end,
    }

    package.loaded["yoda.config_loader"] = mock_config_loader

    -- Mock snacks.picker
    package.loaded["snacks.picker"] = {
      select = function(items, opts, callback)
        -- Auto-select first item for most tests
        callback(items[1])
      end,
    }
  end)

  after_each(function()
    -- Restore original
    package.loaded["yoda.config_loader"] = original_config_loader
    package.loaded["snacks.picker"] = nil
  end)

  describe("handle_yaml_selection()", function()
    it("successfully completes 4-step wizard", function()
      local result = nil

      local env_region = {
        environments = {
          qa = { "auto", "use1" },
          fastly = { "auto" },
          prod = { "auto", "use1" },
        },
        env_order = { "qa", "fastly", "prod" },
      }

      PickerHandler.handle_yaml_selection(env_region, function(selection)
        result = selection
      end)

      -- Should complete with auto-selected values
      assert.is_not_nil(result)
      assert.is_table(result)
      assert.is_not_nil(result.environment)
      assert.is_not_nil(result.region)
      assert.is_not_nil(result.markers)
      assert.is_not_nil(result.open_allure)
    end)

    it("handles user cancellation at step 1", function()
      local result = "NOT_CALLED"

      package.loaded["snacks.picker"] = {
        select = function(items, opts, callback)
          callback(nil) -- User cancelled
        end,
      }

      PickerHandler.handle_yaml_selection({
        environments = { qa = { "auto" } },
        env_order = { "qa" },
      }, function(selection)
        result = selection
      end)

      assert.is_nil(result)
    end)

    it("uses env_order when provided", function()
      local selected_items = {}

      package.loaded["snacks.picker"] = {
        select = function(items, opts, callback)
          table.insert(selected_items, items)
          callback(items[1])
        end,
      }

      PickerHandler.handle_yaml_selection({
        environments = {
          prod = { "auto" },
          qa = { "auto" },
        },
        env_order = { "qa", "prod" }, -- Should respect this order
      }, function() end)

      -- First picker should show environments in env_order
      local first_picker = selected_items[1]
      assert.is_table(first_picker)
    end)
  end)

  describe("handle_json_selection()", function()
    it("generates environment-region combinations", function()
      local result = nil

      local env_region = {
        environments = { "qa", "prod" },
        regions = { "auto", "use1" },
      }

      PickerHandler.handle_json_selection(env_region, function(selection)
        result = selection
      end)

      assert.is_not_nil(result)
      assert.is_table(result)
      assert.is_not_nil(result.environment)
      assert.is_not_nil(result.region)
    end)

    it("parses selected label correctly", function()
      local result = nil

      package.loaded["snacks.picker"] = {
        select = function(items, opts, callback)
          callback("qa (auto)") -- Specific selection
        end,
      }

      PickerHandler.handle_json_selection({
        environments = { "qa" },
        regions = { "auto" },
      }, function(selection)
        result = selection
      end)

      assert.equals("qa", result.environment)
      assert.equals("auto", result.region)
    end)

    it("handles user cancellation", function()
      local result = "NOT_CALLED"

      package.loaded["snacks.picker"] = {
        select = function(items, opts, callback)
          callback(nil) -- User cancelled
        end,
      }

      PickerHandler.handle_json_selection({
        environments = { "qa" },
        regions = { "auto" },
      }, function(selection)
        result = selection
      end)

      assert.is_nil(result)
    end)

    it("handles invalid label format", function()
      local result = "NOT_CALLED"
      local error_notified = false

      -- Mock vim.notify
      local original_notify = vim.notify
      vim.notify = function(msg, level)
        if msg:match("Failed to parse") then
          error_notified = true
        end
      end

      package.loaded["snacks.picker"] = {
        select = function(items, opts, callback)
          callback("invalid label without parentheses")
        end,
      }

      PickerHandler.handle_json_selection({
        environments = { "qa" },
        regions = { "auto" },
      }, function(selection)
        result = selection
      end)

      vim.notify = original_notify

      assert.is_true(error_notified)
      assert.is_nil(result)
    end)
  end)

  describe("reorder_with_default_first() integration", function()
    it("shows cached default first in environment selection", function()
      local presented_items = nil

      mock_config_loader.load_marker = function()
        return { environment = "prod" } -- Cached default
      end

      package.loaded["snacks.picker"] = {
        select = function(items, opts, callback)
          if not presented_items then
            presented_items = vim.deepcopy(items) -- Capture first picker call
          end
          callback(items[1])
        end,
      }

      PickerHandler.handle_yaml_selection({
        environments = {
          qa = { "auto" },
          prod = { "auto" },
        },
        env_order = { "qa", "prod" },
      }, function() end)

      -- First item should be "prod" (cached default), then "qa"
      assert.is_table(presented_items)
      assert.equals("prod", presented_items[1])
      assert.equals("qa", presented_items[2])
    end)
  end)

  describe("wizard step cancellation handling", function()
    it("stops wizard when region selection cancelled", function()
      local step3_called = false

      local call_count = 0
      package.loaded["snacks.picker"] = {
        select = function(items, opts, callback)
          call_count = call_count + 1
          if call_count == 1 then
            callback(items[1]) -- Step 1: Select environment
          elseif call_count == 2 then
            callback(nil) -- Step 2: Cancel region selection
          else
            step3_called = true -- Step 3: Should not be called
            callback(items[1])
          end
        end,
      }

      local result = "NOT_CALLED"
      PickerHandler.handle_yaml_selection({
        environments = { qa = { "auto" } },
        env_order = { "qa" },
      }, function(selection)
        result = selection
      end)

      assert.is_nil(result)
      assert.is_false(step3_called)
    end)
  end)

  describe("cache integration", function()
    it("saves selections to cache", function()
      local saved_data = nil

      mock_config_loader.save_marker = function(path, env, region, markers, allure)
        saved_data = {
          path = path,
          env = env,
          region = region,
          markers = markers,
          allure = allure,
        }
      end

      PickerHandler.handle_yaml_selection({
        environments = { qa = { "auto" } },
        env_order = { "qa" },
      }, function() end)

      -- Should have saved after completing wizard
      assert.is_not_nil(saved_data)
      assert.is_not_nil(saved_data.env)
      assert.is_not_nil(saved_data.region)
    end)
  end)

  -- NOTE: display_current_config() and generate_command_preview() tests removed - functionality moved to pytest-atlas.nvim plugin

  describe("integration with wizard completion", function()
    local original_notify
    local notify_calls = {}

    before_each(function()
      notify_calls = {}
      original_notify = vim.notify
      vim.notify = function(msg, level)
        table.insert(notify_calls, { message = msg, level = level })
      end

      package.loaded["yoda.terminal.venv"] = {
        find_virtual_envs = function()
          return { "/test/venv" }
        end,
      }
    end)

    after_each(function()
      vim.notify = original_notify
      package.loaded["yoda.terminal.venv"] = nil
    end)

    it("displays configuration after YAML wizard completion", function()
      PickerHandler.handle_yaml_selection({
        environments = { qa = { "auto" } },
        env_order = { "qa" },
      }, function() end)

      -- Should have displayed configuration preview
      local has_config_display = false
      for _, call in ipairs(notify_calls) do
        if call.message:match("Test Configuration:") then
          has_config_display = true
          break
        end
      end

      assert.is_true(has_config_display)
    end)

    it("displays configuration after JSON selection completion", function()
      package.loaded["snacks.picker"] = {
        select = function(items, opts, callback)
          callback("qa (auto)")
        end,
      }

      PickerHandler.handle_json_selection({
        environments = { "qa" },
        regions = { "auto" },
      }, function() end)

      -- Should have displayed configuration preview
      local has_config_display = false
      for _, call in ipairs(notify_calls) do
        if call.message:match("Test Configuration:") then
          has_config_display = true
          break
        end
      end

      assert.is_true(has_config_display)
    end)
  end)
end)
