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

      mock_config_loader.save_marker = function(
        path,
        env,
        region,
        markers,
        allure
      )
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

  -- NOTE: display_current_config() and generate_command_preview() tests removed
  -- - functionality moved to pytest-atlas.nvim plugin

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

    it(
      "completes YAML wizard without configuration display (moved to pytest-atlas)",
      function()
        local completed = false
        local result = nil

        PickerHandler.handle_yaml_selection({
          environments = { qa = { "auto" } },
          env_order = { "qa" },
        }, function(config)
          completed = true
          result = config
        end)

        -- Should complete successfully with result
        assert.is_true(completed)
        assert.is_not_nil(result)
        assert.equals("qa", result.environment)
        assert.equals("auto", result.region)
      end
    )

    it(
      "completes JSON selection without configuration display (moved to pytest-atlas)",
      function()
        local completed = false
        local result = nil

        package.loaded["snacks.picker"] = {
          select = function(items, opts, callback)
            callback("qa (auto)")
          end,
        }

        PickerHandler.handle_json_selection({
          environments = { "qa" },
          regions = { "auto" },
        }, function(config)
          completed = true
          result = config
        end)

        -- Should complete successfully with result
        assert.is_true(completed)
        assert.is_not_nil(result)
        assert.equals("qa", result.environment)
        assert.equals("auto", result.region)
      end
    )
  end)

  describe("edge cases exposed by branch instrumentation", function()
    -- Existing tests all drive handle_yaml_selection through a happy path
    -- with pre-populated env/region maps. Adds four tests that exercise
    -- previously-untaken branches:
    --   L110  extract_env_names loop with zero iterations (empty envs)
    --   L183  wizard_step_select_region when the chosen env has no regions
    --   L209 + L275  markers picker cancellation propagates through the chain
    --   L232 + L281  allure picker cancellation propagates through the chain

    it(
      "handles an empty env_region without env_order (extract_env_names loop 0-iter)",
      function()
        -- Arrange
        local result = "NOT_CALLED"

        -- Act: no env_order, no environments key -> for pairs({}) is 0 iters
        PickerHandler.handle_yaml_selection({}, function(selection)
          result = selection
        end)

        -- Assert: picker gets empty items, callback receives nil (cancelled)
        assert.is_nil(result)
      end
    )

    it(
      "extract_env_names iterates environments dict when env_order is absent (L111)",
      function()
        -- Arrange: capture the env names shown in the first picker call.
        local first_picker_items
        package.loaded["snacks.picker"] = {
          select = function(items, _opts, callback)
            if not first_picker_items then
              first_picker_items = items
            end
            callback(items[1])
          end,
        }

        -- Act: no env_order forces the for-pairs loop at L110-112 to run,
        -- exercising the table.insert on L111 for each key.
        PickerHandler.handle_yaml_selection({
          environments = {
            qa = { "auto" },
            prod = { "auto" },
          },
        }, function() end)

        -- Assert: both env keys made it through the loop, sorted.
        assert.is_not_nil(first_picker_items)
        assert.equals(2, #first_picker_items)
        table.sort(first_picker_items)
        assert.equals("prod", first_picker_items[1])
        assert.equals("qa", first_picker_items[2])
      end
    )

    it(
      "warns and cancels when the selected environment has no regions",
      function()
        -- Arrange
        local result = "NOT_CALLED"
        local warn_msg
        local original_notify = vim.notify
        vim.notify = function(msg, level)
          if level == vim.log.levels.WARN then
            warn_msg = msg
          end
        end

        -- Act: env exists but its region list is empty (#regions == 0 branch)
        PickerHandler.handle_yaml_selection({
          environments = { qa = {} },
          env_order = { "qa" },
        }, function(selection)
          result = selection
        end)

        -- Assert
        assert.is_nil(result)
        assert.is_not_nil(warn_msg)
        assert.matches("No regions found", warn_msg)

        vim.notify = original_notify
      end
    )

    it("cancels the wizard when the markers multiselect returns nil", function()
      -- Arrange
      local result = "NOT_CALLED"
      -- yoda-adapters.picker.multiselect is what wizard_step_select_markers
      -- uses. Its minimal_init preload returns all items by default -- swap
      -- for a nil-returning variant to exercise the cancellation path.
      local original_picker = package.loaded["yoda-adapters.picker"]
      package.loaded["yoda-adapters.picker"] = {
        select = original_picker.select,
        multiselect = function(_items, _opts, on_choice)
          on_choice(nil)
        end,
      }

      -- Act
      PickerHandler.handle_yaml_selection({
        environments = { qa = { "auto" } },
        env_order = { "qa" },
      }, function(selection)
        result = selection
      end)

      -- Assert
      assert.is_nil(result)

      package.loaded["yoda-adapters.picker"] = original_picker
    end)

    it("cancels the wizard when the allure prompt returns nil", function()
      -- Arrange
      local result = "NOT_CALLED"
      -- Cancel only on the Allure prompt so env + region pickers proceed
      -- normally; the wizard reaches step 4 and then bails.
      package.loaded["snacks.picker"] = {
        select = function(items, opts, callback)
          if opts.prompt and opts.prompt:match("Allure") then
            callback(nil)
          else
            callback(items[1])
          end
        end,
      }

      -- Act
      PickerHandler.handle_yaml_selection({
        environments = { qa = { "auto" } },
        env_order = { "qa" },
      }, function(selection)
        result = selection
      end)

      -- Assert
      assert.is_nil(result)
    end)
  end)
end)
