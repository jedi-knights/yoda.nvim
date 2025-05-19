-- lua/yoda/testpicker/init.lua
-- Neovim picker for running customized pytest tests

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local valid_envs = { "qa", "prod", "legacy", "fastly" }
local valid_regions = { "auto", "use1", "usw2", "euw1", "apse1" }

local function run_tests(opts)
  local cmd = { "pytest" }

  if not opts.serial then
    table.insert(cmd, "-n")
    table.insert(cmd, "auto")
  end

  if opts.markers ~= nil and opts.markers ~= "" then
    table.insert(cmd, "-m")
    table.insert(cmd, opts.markers)
  else
    table.insert(cmd, "-m")
    table.insert(cmd, "bdd")
  end

  vim.fn.setenv("ENVIRONMENT", opts.environment)
  vim.fn.setenv("REGION", opts.region)
  if opts.markers then
    vim.fn.setenv("MARKERS", opts.markers)
  end

  vim.cmd("botright split | terminal")
  vim.cmd("startinsert")
  vim.fn.chansend(vim.b.terminal_job_id, table.concat(cmd, " ") .. "\n")
end

local function picker(title, items, on_select, default)
  pickers.new({}, {
    prompt_title = title,
    finder = finders.new_table { results = items },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(_, map)
      actions.select_default:replace(function()
        actions.close()
        local entry = action_state.get_selected_entry()
        if not entry then
          vim.notify("No selection made, defaulting to: " .. default, vim.log.levels.INFO)
          on_select(default)
        else
          on_select(entry[1])
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
    endpoint = nil,
  }

  picker("Select Environment", valid_envs, function(env)
    opts.environment = env
    picker("Select Region", valid_regions, function(region)
      opts.region = region
      vim.ui.input({ prompt = "Pytest markers (e.g. smoke and not slow): " }, function(markers)
        if not markers or markers == "" then
          markers = "bdd"
          vim.notify("No markers selected, defaulting to 'bdd'", vim.log.levels.INFO)
        end
        opts.markers = markers
        vim.ui.select({ "Parallel", "Serial" }, { prompt = "Run mode:" }, function(choice)
          opts.serial = (choice == "Serial")
          run_tests(opts)
        end)
      end)
    end, "auto")
  end, "qa")
end

  return M
