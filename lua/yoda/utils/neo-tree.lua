local M = {}

function M.refresh_neotree()
  local ok, neotree = pcall(require, "neo-tree.sources.manager")
  if ok and neotree then
    neotree.refresh("filesystem")
  else
    print("Neo-tree is not available.")
  end
end

return M

