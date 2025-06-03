-- lua/yoda/testpicker/init.lua
-- Neovim picker for running customized pytest tests

local Path = require("plenary.path")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")

local log_path = "output.log"

local function parse_yaml_block(path, key, indent_limit)
  local lines = Path:new(path):readlines()
  local entries = {}
  local seen = {}
  local in_block = false

  for _, line in ipairs(lines) do
    if line:match("^%s*" .. key .. ":%s*$") then
      in_block = true
    elseif in_block then
      local indent, name = line:match("^(%s*)%- name:%s*(%w+)%s*$")
      if indent and name and #indent <= indent_limit then
        if not seen[name] then
          table.insert(entries, name)
          seen[name] = true
        end
      elseif line:match("^%S") then
        in_block = false
      end
    end
  end

  return entries
end

local function load_env_region()
  local files = { "ingress-mapping.yaml", "ingress-mapping.yml" }
  for _, file in ipairs(files) do
    if vim.fn.filereadable(file) == 1 then
      return {
        environments = parse_yaml_block(file, "environments", 4),
        regions = parse_yaml_block(file, "regions", 8),
      }
    end
  end

  return {
    environments = { "qa", "prod" },
    regions = { "auto", "use1", "usw2", "euw1", "apse1" },
  }
end

local function parse_addopts()
  if vim.fn.filereadable("pytest.ini") == 0 then return {} end
  local lines = vim.fn.readfile("pytest.ini")
  local in_ini = false
  for _, line in ipairs(lines) do
    if line:match("^%[pytest%]") then
      in_ini = true
    elseif in_ini and line:match("^addopts%s*=") then
      return vim.split(line:match("^addopts%s*=%s*(.+)$") or "", "%s+")
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

local function picker(title, items, on_select, default)
  local default_index = 1
  for i, item in ipairs(items) do
    if item == default then
      default_index = i
      break
    end
  end

  pickers.new({ prompt_title = title }, {
    finder = finders.new_table { results = items },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        local value = (entry and entry[1]) or default
        vim.notify("Selected: " .. value, vim.log.levels.INFO)
        on_select(value)
      end)

      vim.schedule(function()
        for _ = 1, default_index - 1 do
          actions.move_selection_next(prompt_bufnr)
        end
      end)

      return true
    end,
  }):find()
end

local function run_tests(opts)
  local cmd = { "pytest" }
  vim.list_extend(cmd, parse_addopts())
  if not opts.serial then vim.list_extend(cmd, { "-n", "auto" }) end

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

local M = {}

function M.run()
  local opts = {
    environment = "qa",
    region = "auto",
    markers = "bdd",
    serial = false,
  }

  local env_region = load_env_region()

  picker("Select Environment", env_region.environments, function(env)
    opts.environment = env
    picker("Select Region", env_region.regions, function(region)
      opts.region = region
      vim.ui.select({ "Parallel", "Serial" }, { prompt = "Run mode:" }, function(choice)
        opts.serial = (choice == "Serial")

        local markers = parse_pytest_ini_markers()
        table.sort(markers, function(a, b) return a.marker:lower() > b.marker:lower() end)

        if #markers > 0 then
          multi_select_picker("Select markers", markers, function(selected)
            opts.markers = table.concat(selected, " and ")
            run_tests(opts)
          end)
        else
          vim.ui.input({ prompt = "Pytest markers (e.g. smoke and not slow): " }, function(input)
            opts.markers = input ~= "" and input or "bdd"
            run_tests(opts)
          end)
        end
      end)
    end, "auto")
  end, "qa")
end

return M
