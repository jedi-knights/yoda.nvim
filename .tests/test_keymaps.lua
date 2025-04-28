-- .tests/test_keymaps.lua
local function keymap_exists(mode, lhs)
  local maps = vim.api.nvim_get_keymap(mode)
  for _, map in ipairs(maps) do
    if map.lhs == lhs then
      return true
    end
  end
  return false
end

local function assert_keymap(mode, lhs, desc)
  if not keymap_exists(mode, lhs) then
    error(string.format("Missing keymap: mode=%s lhs=%s (%s)", mode, lhs, desc))
  end
end

-- Example: check your important mappings
assert_keymap("n", "<leader>e", "Toggle file tree")
assert_keymap("n", "<leader>ff", "Find files")
assert_keymap("n", "<leader>fg", "Live grep")
-- Add more assertions as needed

print("All keymap tests passed!")

