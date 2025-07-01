-- lua/yoda/utils/treesitter_cleanup.lua
-- Utility to clean up duplicate TreeSitter parsers

local M = {}

-- Function to clean up duplicate parsers
function M.cleanup_duplicate_parsers()
  local ts_install = require("nvim-treesitter.install")
  
  -- List of parsers that have duplicates
  local duplicate_parsers = {
    "c",
    "lua", 
    "markdown",
    "markdown_inline",
    "query",
    "vim",
    "vimdoc"
  }
  
  vim.notify("🧹 Cleaning up duplicate TreeSitter parsers...", vim.log.levels.INFO)
  
  for _, parser in ipairs(duplicate_parsers) do
    -- Reinstall parser to ensure we only have one copy
    vim.notify("Reinstalling " .. parser .. " parser", vim.log.levels.INFO)
    ts_install.install(parser)
  end
  
  vim.notify("✅ TreeSitter parser cleanup complete!", vim.log.levels.INFO)
end

-- Function to check for duplicates
function M.check_duplicates()
  local parser_info = vim.treesitter.language.inspect()
  local duplicates = {}
  
  for lang, info in pairs(parser_info) do
    if type(info) == "table" and info.path then
      -- Check if parser exists in multiple locations
      local count = 0
      for _ in pairs(info.path) do
        count = count + 1
      end
      if count > 1 then
        table.insert(duplicates, lang)
      end
    end
  end
  
  if #duplicates > 0 then
    vim.notify("Found duplicate parsers: " .. table.concat(duplicates, ", "), vim.log.levels.WARN)
    return duplicates
  else
    vim.notify("✅ No duplicate parsers found", vim.log.levels.INFO)
    return {}
  end
end

return M
