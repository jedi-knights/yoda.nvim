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
  
  -- Check plugin dev status
  local ok, plugin_dev = pcall(require, "yoda.utils.plugin_dev")
  if ok then
    plugin_dev.check_plugin_dev_status()
  end
end, {})

vim.api.nvim_create_user_command("YodaCleanLazy", function()
  -- Clean up Lazy.nvim cache and state
  local lazy_state = vim.fn.stdpath("state") .. "/lazy"
  local lazy_data = vim.fn.stdpath("data") .. "/lazy"
  
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
end, {})

vim.api.nvim_create_user_command("YodaFixPluginDev", function()
  -- Fix plugin development issues
  print("=== Fixing Plugin Development Issues ===")
  
  -- Check plugin_dev.lua configuration
  local config_path = vim.fn.stdpath("config") .. "/plugin_dev.lua"
  if vim.fn.filereadable(config_path) == 1 then
    print("Found plugin_dev.lua configuration")
    
    local ok, config = pcall(dofile, config_path)
    if ok and type(config) == "table" then
      for name, path in pairs(config) do
        local expanded_path = vim.fn.expand(path)
        local exists = vim.fn.isdirectory(expanded_path) == 1
        print(string.format("  %s: %s %s", name, expanded_path, exists and "✓" or "✗"))
        
        if not exists then
          print(string.format("    Warning: Local path for %s does not exist", name))
        end
      end
    else
      print("Error reading plugin_dev.lua:", config)
    end
  else
    print("No plugin_dev.lua found. Create one based on plugin_dev.lua.example")
  end
  
  -- Clean up documentation cache
  local ok, plugin_dev = pcall(require, "yoda.utils.plugin_dev")
  if ok then
    plugin_dev.cleanup_docs_cache()
  end
  
  print("Plugin development issues fixed. Restart Neovim or run :Lazy sync")
end, {}) 