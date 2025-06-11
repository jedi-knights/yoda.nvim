-- lua/yoda/testpicker/init.lua
local Path = require("plenary.path")

local M = {}
local log_path = "output.log"

local function parse_json_config(path)
  local ok, content = pcall(Path.new(path).read, Path.new(path))
  if not ok then return nil end
  local ok_json, parsed = pcall(vim.json.decode, content)
  if not ok_json then return nil end
  return parsed
end

local function load_env_region()
  local file_path = "environments.json"
  if vim.fn.filereadable(file_path) ~= 1 then
    return {
      environments = { "qa", "prod" },
      regions = { "auto", "use1", "usw2", "euw1", "apse1" },
    }
  end

  local config = parse_json_config(file_path)
  if not config then
    return {
      environments = { "qa", "prod" },
      regions = { "auto", "use1", "usw2", "euw1", "apse1" },
    }
  end

  return {
    environments = config.environments or {},
    regions = config.regions or {},
  }
end


local function run_tests(env, region, marker)
  local quoted_marker = string.format('"%s"', marker)

  -- Single-line shell script using && and ;
  local bash_script = string.format(
    "bash -c %q",
    string.format([[
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
  )

  -- Use :FloatermNew as a Vim command, passing the entire bash -c string as argument
  local floaterm_cmd = string.format("FloatermNew --autoclose=0 %s", bash_script)
  vim.api.nvim_command(floaterm_cmd)
end


function M.run()
  local env_region_config = load_env_region()
  local valid_envs = env_region_config.environments
  local valid_regions = env_region_config.regions

  vim.ui.input({ prompt = "Enter environment (" .. table.concat(valid_envs, ", ") .. "): ", default = "qa" }, function(env)
    if not env or env == "" then return end
    vim.ui.input({ prompt = "Enter region (" .. table.concat(valid_regions, ", ") .. "): ", default = "auto" }, function(region)
      if not region or region == "" then return end
      vim.ui.input({ prompt = "Enter pytest marker: ", default = "" }, function(marker)
        if not marker or marker == "" then return end
        run_tests(env, region, marker)
      end)
    end)
  end)
end

return M
