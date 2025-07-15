-- lua/yoda/testpicker.lua

local Path = require("plenary.path")
local json = vim.json
local M = {}

-- Pre-load the picker module to avoid delay during selection
local picker = require("snacks.picker")

local log_path = "output.log"
local cache_file = vim.fn.stdpath("cache") .. "/yoda_testpicker_marker.json"

local function parse_json_config(path)
  local ok, content = pcall(Path.new(path).read, Path.new(path))
  if not ok then return nil end
  local ok_json, parsed = pcall(json.decode, content)
  if not ok_json then return nil end
  return parsed
end

local function load_env_region()
  local fallback = {
    environments = { "qa", "prod" },
    regions = { "auto", "use1", "usw2", "euw1", "apse1" },
  }

  local file_path = "environments.json"
  if vim.fn.filereadable(file_path) ~= 1 then
    return fallback
  end

  local config = parse_json_config(file_path)
  if not config then return fallback end

  return {
    environments = config.environments or fallback.environments,
    regions = config.regions or fallback.regions,
  }
end

local function get_last_marker()
  if vim.fn.filereadable(cache_file) == 1 then
    local ok, content = pcall(Path.new(cache_file).read, Path.new(cache_file))
    if ok then
      local ok_json, parsed = pcall(json.decode, content)
      if ok_json and parsed.marker then
        return parsed.marker
      end
    end
  end
  return ""
end

local function save_last_marker(marker)
  print("Saving last marker:", marker)
  local encoded = json.encode({ marker = marker })
  pcall(Path.new(cache_file).write, Path.new(cache_file), encoded, "w")
end

local function run_tests(env, region, marker, serve_allure)
  local quoted_marker = string.format('"%s"', marker)
  local bash_script = string.format([[  
    [ -f junit.xml ] && rm junit.xml
    [ -f coverage.xml ] && rm coverage.xml
    [ -f .coverage ] && rm .coverage
    [ -d allure-results ] && rm -rf allure-results
    ENVIRONMENT=%s REGION=%s pytest -n auto -m %s 2>&1 | tee %s
    if [ -d allure-results ]; then
      %s
    else
      echo '⚠️  No allure-results directory found.'
    fi
    echo "Press Enter to close..."; read
  ]], env, region, quoted_marker, log_path, serve_allure and "echo '🧪 Launching Allure report...'; allure serve allure-results;" or "echo 'Allure report not served.';")

  -- Use vim.schedule to defer terminal creation for faster UI response
  vim.schedule(function()
    Snacks.terminal.open({ "bash", "-c", bash_script }, {
      win = {
        relative = "editor",
        position = "float",
        width = 0.9,
        height = 0.85,
        border = "rounded",
        title = " Test Runner ",
        title_pos = "center",
      },
      -- Optimize terminal startup
      start_insert = false,  -- Don't start in insert mode immediately
      auto_insert = false,   -- Don't auto-insert on buffer enter
    })
  end)
end

function M.run()
  local cfg = load_env_region()
  local last_marker = get_last_marker()

  picker.select(cfg.environments, {
    prompt = "Select environment:",
  }, function(env)
    if not env then return end
    print("Selected env:", env)

    picker.select(cfg.regions, {
      prompt = "Select region:",
    }, function(region)
      if not region then return end
      print("Selected region:", region)

      Snacks.input({
        prompt = "Enter pytest marker:",
        default = last_marker,
      }, function(marker)
        if not marker or marker == "" then return end
        save_last_marker(marker)
        -- Add a picker for whether to serve the Allure report
        picker.select({"No", "Yes"}, {
          prompt = "Serve Allure report after tests?",
          default = 1, -- Default to 'No'
        }, function(serve_allure)
          if not serve_allure then return end
          run_tests(env, region, marker, serve_allure == "Yes")
        end)
      end)
    end)
  end)
end

return M
