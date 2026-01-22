-- lua/yoda/diagnose_signs.lua
-- Diagnostic tool for sign column flickering

local M = {}

function M.diagnose()
  print("=== SIGN COLUMN FLICKERING DIAGNOSTIC ===")
  print("")

  -- Check sign column settings
  print("1. Sign Column Settings:")
  print(string.format("   signcolumn: %s", vim.o.signcolumn))
  print(string.format("   number: %s", tostring(vim.o.number)))
  print(string.format("   relativenumber: %s", tostring(vim.o.relativenumber)))
  print("")

  -- Check what signs are defined
  print("2. Defined Signs:")
  local signs = vim.fn.sign_getdefined()
  local git_count = 0
  local diag_count = 0
  for _, sign in ipairs(signs) do
    if sign.name:match("Git") then
      git_count = git_count + 1
    elseif sign.name:match("Diagnostic") then
      diag_count = diag_count + 1
    end
  end
  print(string.format("   Git signs: %d", git_count))
  print(string.format("   Diagnostic signs: %d", diag_count))
  print(string.format("   Total: %d", #signs))
  print("")

  -- Check placed signs in current buffer
  print("3. Placed Signs in Current Buffer:")
  local buf = vim.api.nvim_get_current_buf()
  local placed = vim.fn.sign_getplaced(buf)
  if #placed > 0 and placed[1].signs then
    local count = #placed[1].signs
    print(string.format("   Total: %d signs", count))
    if count > 0 and count < 10 then
      for _, sign in ipairs(placed[1].signs) do
        print(string.format("   Line %d: %s", sign.lnum, sign.name))
      end
    end
  else
    print("   No signs placed")
  end
  print("")

  -- Check gitsigns status
  print("4. Gitsigns:")
  local gs = package.loaded.gitsigns
  if gs then
    print("   ✅ Gitsigns loaded")
    local status = vim.b.gitsigns_status_dict
    if status then
      print(string.format("   Added: %d, Changed: %d, Removed: %d", status.added or 0, status.changed or 0, status.removed or 0))
    end
  else
    print("   ❌ Gitsigns not loaded")
  end
  print("")

  -- Check for performance issues
  print("5. Autocmd Performance:")
  print("   ℹ️  Performance tracking removed - use :profile for diagnostics")
  print("")

  -- Recommendations
  print("6. Recommendations:")
  local has_issue = false

  if git_count > 10 then
    print("   ⚠️  Many git signs defined - could cause flickering")
    has_issue = true
  end

  if vim.o.signcolumn == "auto" then
    print("   ℹ️  Consider 'signcolumn=yes' for stable width")
  end

  if not has_issue then
    print("   ✅ No obvious issues detected")
  end
  print("")
  print("=== END DIAGNOSTIC ===")
end

-- Create command
vim.api.nvim_create_user_command("DiagnoseSigns", function()
  M.diagnose()
end, { desc = "Diagnose sign column flickering" })

return M
