-- lua/yoda/commands/formatting.lua
-- Feature file (Gherkin) formatting commands

local M = {}

local notify = require("yoda-adapters.notification")

--- Trim trailing whitespace from all lines in current buffer
local function trim_trailing_whitespace()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local updated = {}

  for _, line in ipairs(lines) do
    table.insert(updated, (line:gsub("%s+$", "")))
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, updated)
  notify.notify("✅ Trailing whitespace removed", "info")
end

--- Format an Examples table block
local function format_example_block(lines)
  local result = {}
  local widths = {}

  for _, line in ipairs(lines) do
    local cells = {}
    for cell in line:gmatch("%s*|%s*([^|]*)") do
      table.insert(cells, cell:match("^%s*(.-)%s*$"))
    end
    table.insert(result, cells)

    for i, cell in ipairs(cells) do
      widths[i] = math.max(widths[i] or 0, #cell)
    end
  end

  local formatted = {}
  for _, cells in ipairs(result) do
    local parts = {}
    for i, cell in ipairs(cells) do
      local padded = cell .. string.rep(" ", widths[i] - #cell)
      table.insert(parts, padded)
    end
    table.insert(formatted, "      | " .. table.concat(parts, " | ") .. " |")
  end

  return formatted
end

--- Fix alignment of Examples blocks in feature files
local function fix_feature_examples()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local updated = {}
  local in_examples = false
  local example_lines = {}

  for _, line in ipairs(lines) do
    if line:match("^%s*Examples:") then
      in_examples = true
      table.insert(updated, line)
    elseif in_examples and line:match("|") then
      table.insert(example_lines, line)
    else
      if in_examples and #example_lines > 0 then
        vim.list_extend(updated, format_example_block(example_lines))
        example_lines = {}
        in_examples = false
      end
      table.insert(updated, line)
    end
  end

  if #example_lines > 0 then
    vim.list_extend(updated, format_example_block(example_lines))
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, updated)
  notify.notify("✅ Examples blocks aligned", "info")
end

--- Format the current feature file
local function format_feature()
  fix_feature_examples()
  trim_trailing_whitespace()
end

function M.setup()
  vim.api.nvim_create_user_command("FormatFeature", function()
    format_feature()
  end, { desc = "Format Gherkin feature file" })
end

return M
