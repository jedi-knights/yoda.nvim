-- lua/yoda/utils/generate_keymaps_doc.lua

local function GenerateKeymapsDoc()
  local tracker = require("yoda.utils.keymap_tracker")
  local filepath = vim.fn.stdpath("config") .. "/docs/KEYMAPS.md"

  local lines = {}
  table.insert(lines, "# Keymap Cheatsheet\n")
  table.insert(lines, "")
  table.insert(lines, "| Mode | Key | Action |")
  table.insert(lines, "|:----|:----|:-------|")

  for _, km in ipairs(tracker.keymaps) do
    table.insert(lines, string.format("| %s | %s | %s |", km.mode, km.lhs, km.desc))
  end

  vim.fn.mkdir(vim.fn.stdpath("config") .. "/docs", "p") -- Ensure docs/ exists
  vim.fn.writefile(lines, filepath)

  print("✅ Generated docs/KEYMAPS.md")
end

return GenerateKeymapsDoc

