-- lua/yoda/testpicker/init.lua
-- Neovim picker for running customized pytest tests

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")

local log_path = "output.log"
local valid_envs = { "qa", "prod", "legacy", "fastly" }
local valid_regions = { "auto", "use1", "usw2", "euw1", "apse1" }

local function parse_pytest_ini_markers()
  local markers = {}
  if vim.fn.filereadable("pytest.ini") == 1 then
    local lines = vim.fn.readfile("pytest.ini")
    local in_markers = false
    for _, line in ipairs(lines) do
      if line:match("^markers") then
        in_markers = true
      elseif in_markers then
        local trimmed = line:match("^%s*%-?%s*(%S+):%s*(.+)$")
        if trimmed then
          local marker, desc = line:match("^%s*%-?%s*(%S+):%s*(.+)$")
          if marker and desc then
            table.insert(markers, { marker = marker, desc = desc })
          end
        elseif line:match("^%[.*%]") then
          break -- end of markers section
        end
      end
    end
  end
  return markers
end

local function multi_select_picker(title, items, on_submit)
  local results = {}
  local displayer = entry_display.create {
    separator = " ▏",
    items = {
      { width = 20 },
      { remaining = true },
    },
  }

  pickers.new({}, {
    prompt_title = title,
    finder = finders.new_table {
      results = items,
      entry_maker = function(entry)
        return {
          value = entry,
          display = function(e)
            return displayer {
              e.value.marker,
              e.value.desc,
            }
          end,
          ordinal = entry.marker,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local toggle = function()
        local entry = action_state.get_selected_entry()
        if entry then
          results[entry.value.marker] = not results[entry.value.marker]
        end
      end

      map("<CR>", function()
        actions.close(prompt_bufnr)
        local selected = {}
        for marker, chosen in pairs(results) do
          if chosen then table.insert(selected, marker) end
        end
        on_submit(selected)
      end)

      map({ "<Tab>" }, function()
        toggle()
        local entry = action_state.get_selected_entry()
        if entry then
          vim.notify((results[entry.value.marker] and "+ " or "- ") .. entry.value.marker)
        end
      end)

      return true
    end,
  }):find()
end


local function run_tests(opts)
  local cmd = { "pytest" }

  if not opts.serial then
    table.insert(cmd, "-n")
    table.insert(cmd, "auto")
  end

  if opts.markers == nil or opts.markers  == "" then
    opts.markers = "bdd"
  end

  table.insert(cmd, "-m")
  table.insert(cmd, string.format('"%s"', opts.markers))

  vim.fn.setenv("ENVIRONMENT", opts.environment)
  vim.fn.setenv("REGION", opts.region)
  vim.fn.setenv("MARKERS", opts.markers)

  table.insert(cmd, string.format("--tb=short"))
  table.insert(cmd, string.format("--capture=tee-sys"))

  -- Delete old log if it exists
  if vim.fn.filereadable(log_path) == 1 then
    vim.fn.delete(log_path)
  end

  vim.cmd("botright split | terminal")
  vim.cmd("startinsert")

  local tee_cmd = string.format("%s 2>&1 | tee %s", table.concat(cmd, " "), log_path)
  vim.fn.chansend(vim.b.terminal_job_id, tee_cmd .. "\n")
end

local function picker(title, items, on_select, default)
  pickers.new({}, {
    prompt_title = title,
    finder = finders.new_table { results = items },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        local value = (entry and entry[1]) or default
        if value then
          vim.notify("Selected: " .. value, vim.log.levels.INFO)
          on_select(value)
        else
          vim.notify("No selection or default provided", vim.log.levels.ERROR)
        end
      end)
      return true
    end,
  }):find()
end

local M = {}

function M.run()
  local opts = {
    environment = nil,
    region = nil,
    markers = nil,
    serial = false,
  }

  picker("Select Environment", valid_envs, function(env)
    opts.environment = env
    picker("Select Region", valid_regions, function(region)
      opts.region = region
      vim.ui.select({ "Parallel", "Serial" }, { prompt = "Run mode:" }, function(choice)
        opts.serial = (choice == "Serial")

        local markers = parse_pytest_ini_markers()
        if #markers > 0 then
          multi_select_picker("Select markers", markers, function(selected)
            opts.markers = table.concat(selected, " and ")
            run_tests(opts)
          end)
        else
          vim.ui.input({ prompt = "Pytest markers (e.g. smoke and not slow): " }, function(user_markers)
            if not user_markers or user_markers == "" then
              user_markers = "bdd"
              vim.notify("No markers selected, defaulting to 'bdd'", vim.log.levels.INFO)
            end
            opts.markers = user_markers
            run_tests(opts)
          end)
        end
      end)
    end, "auto")
  end, "qa")
end

return M
