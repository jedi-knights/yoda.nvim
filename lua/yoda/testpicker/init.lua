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

local function parse_block(path, section_key)
  local lines = Path:new(path):readlines()
  local results = {}
  local seen = {}
  local in_section = false

  for _, line in ipairs(lines) do
    if line:match("^%s*" .. section_key .. ":%s*$") then
      in_section = true
    elseif in_section then
      local indent, name = line:match("^(%s*)%- name:%s*(%w+)%s*$")
      if indent and name then
        if not seen[name] then
          table.insert(results, name)
          seen[name] = true
        end
      elseif line:match("^%S") then
        break -- exit section on next top-level key
      end
    end
  end

  return results
end

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

  return {
    environments = parse_block(file_path, "environments"),
    regions = parse_block(file_path, "regions"),
  }
end

local env_region_config = load_env_region_from_ingress_mapping()
local valid_envs = env_region_config.environments
local valid_regions = env_region_config.regions

-- The rest of the code remains unchanged (Telescope pickers and run_tests logic)
-- ...
