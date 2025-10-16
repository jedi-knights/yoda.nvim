-- lua/yoda/lsp/services/filetype_detector.lua
-- Intelligent filetype detection service

local M = {}

--- @class FiletypeDetector
--- @field private _logger table
local FiletypeDetector = {}
FiletypeDetector.__index = FiletypeDetector

--- Create new filetype detector
--- @param logger table Logger service
--- @return FiletypeDetector
function M.new(logger)
  local self = setmetatable({}, FiletypeDetector)
  self._logger = logger
  return self
end

--- Detect if a YAML file is a Helm template
--- @param filepath string Path to the file
--- @return boolean
function FiletypeDetector:is_helm_template(filepath)
  if type(filepath) ~= "string" or filepath == "" then
    return false
  end

  local path_lower = filepath:lower()

  -- Directory-based detection (highest confidence)
  if self:_is_helm_directory_structure(path_lower) then
    return true
  end

  -- Chart root file detection
  if self:_has_chart_files_nearby(filepath) then
    return true
  end

  -- Helper template detection
  if self:_is_helper_template(filepath) then
    return true
  end

  -- Content-based detection
  return self:_has_helm_content(filepath)
end

--- Check if file is in Helm directory structure
--- @param path_lower string Lowercase file path
--- @return boolean
--- @private
function FiletypeDetector:_is_helm_directory_structure(path_lower)
  return path_lower:match("/templates/[^/]*%.ya?ml$") ~= nil
    or path_lower:match("/charts/.*/templates/") ~= nil
    or path_lower:match("/crds/[^/]*%.ya?ml$") ~= nil
end

--- Check if Chart files exist in same directory
--- @param filepath string File path
--- @return boolean
--- @private
function FiletypeDetector:_has_chart_files_nearby(filepath)
  local dirname = vim.fn.fnamemodify(filepath, ":h")
  local chart_files = { "Chart.yaml", "Chart.yml", "values.yaml", "values.yml" }

  for _, chart_file in ipairs(chart_files) do
    if vim.fn.filereadable(dirname .. "/" .. chart_file) == 1 then
      return true
    end
  end
  return false
end

--- Check if file is a Helm helper template
--- @param filepath string File path
--- @return boolean
--- @private
function FiletypeDetector:_is_helper_template(filepath)
  local filename = vim.fn.fnamemodify(filepath, ":t")
  return filename:match("^_.*%.tpl$") ~= nil or filename:match("^_helpers%.") ~= nil or filename == "NOTES.txt"
end

--- Check file content for Helm patterns
--- @param filepath string File path
--- @return boolean
--- @private
function FiletypeDetector:_has_helm_content(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return false
  end

  local line_count = 0
  local max_lines = 20 -- Performance limit

  for line in file:lines() do
    line_count = line_count + 1
    if line_count > max_lines then
      break
    end

    if self:_is_helm_template_line(line) then
      file:close()
      return true
    end
  end

  file:close()
  return false
end

--- Check if line contains Helm template patterns
--- @param line string Line content
--- @return boolean
--- @private
function FiletypeDetector:_is_helm_template_line(line)
  local helm_patterns = {
    "{{%s*%.Release%.",
    "{{%s*%.Values%.",
    "{{%s*%.Chart%.",
    '{{%s*include%s+"',
    '{{%s*template%s+"',
  }

  for _, pattern in ipairs(helm_patterns) do
    if line:match(pattern) then
      return true
    end
  end

  return false
end

--- Setup automatic filetype detection for YAML/Helm files
function FiletypeDetector:setup_yaml_helm_detection()
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.yaml", "*.yml" },
    callback = function()
      local filepath = vim.fn.expand("%:p")
      local filetype = self:is_helm_template(filepath) and "helm" or "yaml"

      vim.bo.filetype = filetype
      self._logger.debug("Detected filetype", {
        file = filepath,
        filetype = filetype,
        detector = "yaml_helm",
      })
    end,
    group = vim.api.nvim_create_augroup("YamlHelmDetection", { clear = true }),
    desc = "Intelligent YAML/Helm filetype detection",
  })
end

return M
