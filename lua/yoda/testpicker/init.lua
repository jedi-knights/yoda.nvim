-- lua/yoda/testpicker/init.lua
-- Neovim picker for running customized pytest tests

local vendor = require("yoda.vendor.vendor")
local yaml = vendor.require("yaml")

if not yaml then
  vim.notify("Failed to load YAML vendor module", vim.log.levels.ERROR)
  return
end

if not yaml.eval then
  vim.notify("Vendored yaml module is invalid", vim.log.levels.ERROR)
  return
end

local Path = require("plenary.path")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")

local log_path = "output.log"

local function load_env_region_from_ingress_mapping()
  local candidates = { "ingress-mapping.yaml", "ingress-mapping.yml" }
  local file_path = nil

  for _, filename in ipairs(candidates) do
    if vim.fn.filereadable(filename) == 1 then
      file_path = filename
      break
    end
  end

  if not file_path then
    return {
      environments = { "qa", "prod" },
      regions = { "auto", "use1", "usw2", "euw1", "apse1" },
    }
  end

  local content = Path:new(file_path):read()
  local parsed = yaml.eval(content)

  if not parsed or type(parsed.environments) ~= "table" then
    vim.notify("Malformed ingress-mapping file. Falling back to default envs/regions.", vim.log.levels.WARN)
    return {
      environments = { "qa", "prod" },
      regions = { "auto", "use1", "usw2", "euw1", "apse1" },
    }
  end

  local envs = {}
  local region_set = {}

  for _, env in ipairs(parsed.environments or {}) do
    table.insert(envs, env.name)
    for _, region in ipairs(env.regions or {}) do
      region_set[region.name] = true
    end
  end

  local regions = {}
  for region in pairs(region_set) do
    table.insert(regions, region)
  end

  table.sort(envs)
  table.sort(regions)

  return {
    environments = envs,
    regions = regions,
  }
end

local env_region_config = load_env_region_from_ingress_mapping()
local valid_envs = env_region_config.environments
local valid_regions = env_region_config.regions

local function parse_addopts()
  if vim.fn.filereadable("pytest.ini") == 0 then
    return {}
  end

  local lines = vim.fn.readfile("pytest.ini")
  local in_ini = false
  for _, line in ipairs(lines) do
    if line:match("^%[pytest%]") then
      in_ini = true
    elseif in_ini and line:match("^addopts%s*=") then
      local opts_str = line:match("^addopts%s*=%s*(.+)$")
      if opts_str then
        return vim.split(opts_str, "%s+")
      end
    elseif line:match("^%[.*%]") then
      break
    end
  end

  return {}
end

local function parse_pytest_ini_markers()
  local markers = {}
  if vim.fn.filereadable("pytest.ini") == 1 then
    local lines = vim.fn.readfile("pytest.ini")
    local in_markers = false
    for _, line in ipairs(lines) do
      if line:match("^markers") then
        in_markers = true
      elseif in_markers then
        local marker, desc = line:match("^%s*%-?%s*(%S+):%s*(.+)$")
        if marker and desc then
          table.insert(markers, { marker = marker, desc = desc })
        elseif line:match("^%[.*%]") then
          break
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

  local function make_finder()
    return finders.new_table {
      results = items,
      entry_maker = function(entry)
        return {
          value = entry,
          ordinal = entry.marker,
          display = function(e)
            local checked = results[e.ordinal] and "[x]" or "[ ]"
            return displayer {
              checked .. " " .. e.value.marker,
              e.value.desc,
            }
          end,
        }
      end,
    }
  end

  for _, item in ipairs(items) do
    if item.marker == "bdd" then
      results[item.marker] = true
    end
  end

  local picker = pickers.new({ prompt_title = title }, {
    finder = make_finder(),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local toggle = function()
        local entry = action_state.get_selected_entry()
        if entry then
          results[entry.ordinal] = not results[entry.ordinal]
          picker:refresh(make_finder())
        end
      end

      map("i", "<CR>", function()
        actions.close(prompt_bufnr)
        local selected = {}
        for _, entry in ipairs(items) do
          if results[entry.marker] then
            table.insert(selected, entry.marker)
          end
        end
        on_submit(selected)
      end)

      map("i", "<C-t>", function()
        toggle()
        local entry = action_state.get_selected_entry()
        if entry then
          vim.notify((results[entry.ordinal] and "+ " or "- ") .. entry.ordinal)
        end
      end)

      map("i", "j", actions.move_selection_next)
      map("i", "k", actions.move_selection_previous)
      map("n", "j", actions.move_selection_next)
      map("n", "k", actions.move_selection_previous)

      return true
    end,
  })

  picker:find()
end

local function run_tests(opts)
  local cmd = { "pytest" }

  vim.list_extend(cmd, parse_addopts())

  if not opts.serial then
    vim.list_extend(cmd, { "-n", "auto" })
  end

  if not opts.markers or opts.markers == "" then
    opts.markers = "bdd"
  end

  vim.fn.setenv("ENVIRONMENT", opts.environment)
  vim.fn.setenv("REGION", opts.region)
  vim.fn.setenv("MARKERS", opts.markers)

  vim.list_extend(cmd, {
    "-m", string.format('"%s"', opts.markers),
    "--tb=short",
    "--capture=tee-sys",
  })

  if vim.fn.filereadable(log_path) == 1 then
    vim.fn.delete(log_path)
  end

  vim.cmd("botright split | terminal")
  vim.cmd("startinsert")

  local tee_cmd = string.format("%s 2>&1 | tee %s", table.concat(cmd, " "), log_path)
  vim.fn.chansend(vim.b.terminal_job_id, tee_cmd .. "\n")
end

local function picker(title, items, on_select, default)
  pickers.new({ prompt_title = title }, {
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
        table.sort(markers, function(a, b)
          return a.marker:lower() > b.marker:lower()
        end)

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
