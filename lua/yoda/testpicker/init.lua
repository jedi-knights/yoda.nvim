-- lua/yoda/testpicker.lua

local snacks = require("snacks")
local Path = require("plenary.path")
local json = vim.json
local M = {}

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
  local encoded = json.encode({ marker = marker })
  pcall(Path.new(cache_file).write, Path.new(cache_file), encoded, "w")
end

local function run_tests(env, region, marker)
  local quoted_marker = string.format('"%s"', marker)
  local bash_script = string.format([[
    [ -f junit.xml ] && rm junit.xml;
    [ -f coverage.xml ] && rm coverage.xml;
    [ -f .coverage ] && rm .coverage;
    [ -d allure-results ] && rm -rf allure-results;
    ENVIRONMENT=%s REGION=%s pytest -n auto -m %s | tee %s;
    if [ -d allure-results ]; then
      echo '🧪 Launching Allure report...';
      allure serve allure-results;
    else
      echo '⚠️  No allure-results directory found.';
    fi
  ]], env, region, quoted_marker, log_path)

  snacks.terminal.open({
    id = "test-run",
    cmd = { "bash", "-c", bash_script },
    win = {
      relative = "editor",
      position = "float",
      width = 0.9,
      height = 0.85,
      border = "rounded",
      title = " Test Runner ",
      title_pos = "center",
    },
  })
end

function M.run()
  local cfg = load_env_region()
  local last_marker = get_last_marker()

  snacks.select(cfg.environments, {
    prompt = "Select environment:",
  }, function(env)
    if not env then return end

    snacks.select(cfg.regions, {
      prompt = "Select region:",
    }, function(region)
      if not region then return end

      snacks.input({
        prompt = "Enter pytest marker:",
        default = last_marker,
      }, function(marker)
        if not marker or marker == "" then return end
        save_last_marker(marker)
        run_tests(env, region, marker)
      end)
    end)
  end)
end

return M
