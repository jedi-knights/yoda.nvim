local M = {}

--- Trim trailing whitespace from all lines
function M.trim_trailing_whitespace()
  vim.cmd([[%s/\s\+$//e]])
end

--- Parse a Gherkin table row into trimmed cells, including trailing cells
local function parse_gherkin_row(line)
  local cells = {}
  local stripped = line:match("^%s*|(.-)|%s*$")
  if not stripped then
    return {}
  end
  for cell in stripped:gmatch("[^|]+") do
    table.insert(cells, vim.trim(cell))
  end
  return cells
end

--- Compute maximum width for each column
local function get_column_widths(rows)
  local widths = {}
  for _, row in ipairs(rows) do
    for i, cell in ipairs(row) do
      widths[i] = math.max(widths[i] or 0, #cell)
    end
  end
  return widths
end

--- Build formatted rows with aligned columns
local function build_aligned_rows(rows, col_widths)
  local formatted = {}
  for _, row in ipairs(rows) do
    local line = "      |"
    for i, cell in ipairs(row) do
      local padded = " " .. cell .. string.rep(" ", col_widths[i] - #cell) .. " "
      line = line .. padded .. "|"
    end
    table.insert(formatted, line)
  end
  return formatted
end

--- Format a block of Examples rows
local function format_example_block(raw_lines)
  local parsed = {}
  for _, line in ipairs(raw_lines) do
    table.insert(parsed, parse_gherkin_row(line))
  end
  local col_widths = get_column_widths(parsed)
  return build_aligned_rows(parsed, col_widths)
end

--- Fix all Examples blocks in the current buffer
function M.fix_feature_examples()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local updated = {}
  local in_examples = false
  local example_lines = {}

  for _, line in ipairs(lines) do
    if line:match("^%s*Examples:") then
      in_examples = true
      if #example_lines > 0 then
        vim.list_extend(updated, format_example_block(example_lines))
        example_lines = {}
      end
      table.insert(updated, line)
    elseif in_examples and line:match("^%s*|") then
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
  vim.notify("✅ Examples blocks aligned", vim.log.levels.INFO)
end

--- Format the current feature file
function M.format_feature()
  M.fix_feature_examples()
  M.trim_trailing_whitespace()
end

--- Register commands
function M.setup()
  vim.api.nvim_create_user_command("DeletePytestMarks", function()
    vim.cmd([[g/@pytest\.mark/d]])
  end, {})

  vim.api.nvim_create_user_command("FormatFeature", function()
    M.format_feature()
  end, {})
  
  vim.api.nvim_create_user_command("YodaDiagnostics", function()
    require("yoda.diagnostics").run_diagnostics()
  end, { desc = "Run Yoda.nvim diagnostics to check LSP and AI integration" })
end

return M
