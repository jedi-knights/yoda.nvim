-- ============================================================================
-- FEATURE FILE FORMATTING COMMANDS
-- ============================================================================

--- Trim trailing whitespace from all lines
local function trim_trailing_whitespace()
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
local function fix_feature_examples()
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
local function format_feature()
  fix_feature_examples()
  trim_trailing_whitespace()
end

-- ============================================================================
-- COMMAND REGISTRATION
-- ============================================================================

-- Add debugging and troubleshooting commands
vim.api.nvim_create_user_command("YodaDebugLazy", function()
  -- Check Lazy.nvim status
  print("=== Lazy.nvim Debug Information ===")
  print("Lazy.nvim path:", vim.fn.stdpath("data") .. "/lazy/lazy.nvim")
  print("Plugin state path:", vim.fn.stdpath("state") .. "/lazy")

  -- Check if Lazy.nvim is loaded
  local ok, lazy = pcall(require, "lazy")
  if ok then
    print("Lazy.nvim loaded successfully")

    -- Check plugin status
    local plugins = lazy.get_plugins()
    print("Total plugins:", #plugins)

    -- Check for problematic plugins
    for _, plugin in ipairs(plugins) do
      if plugin._.loaded and plugin._.load_error then
        print("Plugin with error:", plugin.name, "-", plugin._.load_error)
      end
    end
  else
    print("Lazy.nvim failed to load:", lazy)
  end
end, { desc = "Debug Lazy.nvim plugin manager" })

vim.api.nvim_create_user_command("YodaCleanLazy", function()
  -- Clean up Lazy.nvim cache and state
  local lazy_state = vim.fn.stdpath("state") .. "/lazy"

  print("Cleaning Lazy.nvim cache...")

  -- Clean readme directory
  local readme_dir = lazy_state .. "/readme"
  if vim.fn.isdirectory(readme_dir) == 1 then
    vim.fn.delete(readme_dir, "rf")
    print("Cleaned readme directory")
  end

  -- Clean lock file
  local lock_file = lazy_state .. "/lock.json"
  if vim.fn.filereadable(lock_file) == 1 then
    vim.fn.delete(lock_file)
    print("Cleaned lock file")
  end

  -- Clean cache directory
  local cache_dir = lazy_state .. "/cache"
  if vim.fn.isdirectory(cache_dir) == 1 then
    vim.fn.delete(cache_dir, "rf")
    print("Cleaned cache directory")
  end

  print("Lazy.nvim cache cleaned. Restart Neovim to reload plugins.")
end, { desc = "Clean Lazy.nvim cache and state" })

-- Feature file formatting commands
vim.api.nvim_create_user_command("FormatFeature", function()
  format_feature()
end, { desc = "Format Gherkin feature file" })

-- Diagnostic commands
vim.api.nvim_create_user_command("YodaDiagnostics", function()
  local ok, functions = pcall(require, "yoda.functions")
  if ok and functions.run_diagnostics then
    functions.run_diagnostics()
  else
    vim.notify("Diagnostics not available", vim.log.levels.ERROR)
  end
end, { desc = "Run Yoda.nvim diagnostics to check LSP and AI integration" })
