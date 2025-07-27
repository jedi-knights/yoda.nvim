-- lua/yoda/utils/plugin_helpers.lua
-- Utility functions for plugin configuration patterns

local M = {}

-- Helper function for DRY plugin configuration
function M.create_plugin_spec(name, remote_spec, opts)
  local plugin_dev = require("yoda.utils.plugin_dev")
  opts = opts or {}
  return plugin_dev.local_or_remote_plugin(name, remote_spec, opts)
end

-- Helper function for LSP server configuration
function M.create_lsp_server_spec(server_name, config_opts)
  config_opts = config_opts or {}
  
  return {
    server_name,
    config = function()
      require("lspconfig")[server_name].setup(config_opts)
    end,
  }
end

-- Helper function for telescope extension configuration
function M.create_telescope_extension(extension_name, config_opts)
  config_opts = config_opts or {}
  
  return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      extension_name,
    },
    config = function()
      require("telescope").load_extension(extension_name:match("telescope%-([^/]+)"))
      if config_opts.setup then
        config_opts.setup()
      end
    end,
  }
end

-- Helper function for treesitter parser configuration
function M.create_treesitter_parser(parser_name, config_opts)
  config_opts = config_opts or {}
  
  return {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if not opts.ensure_installed then
        opts.ensure_installed = {}
      end
      table.insert(opts.ensure_installed, parser_name)
      
      if config_opts.override then
        if not opts.override then
          opts.override = {}
        end
        opts.override[parser_name] = config_opts.override
      end
    end,
  }
end

-- Helper function for keymap registration with validation
function M.register_keymaps(mode, mappings, validator)
  for key, config in pairs(mappings) do
    local rhs = config[1]
    local opts = config[2] or {}
    
    -- Validate keymap if validator provided
    if validator and not validator(key, rhs, opts) then
      vim.notify(string.format("Invalid keymap: %s", key), vim.log.levels.WARN)
      goto continue
    end
    
    -- Log the keymap for debugging purposes
    local info = debug.getinfo(2, "Sl")
    local log_record = {
      mode = mode,
      lhs = key,
      rhs = (type(rhs) == "string") and rhs or "<function>",
      desc = opts.desc or "",
      source = info.short_src .. ":" .. info.currentline,
    }
    
    -- Store in global log if available
    if _G.yoda_keymap_log then
      table.insert(_G.yoda_keymap_log, log_record)
    end
    
    vim.keymap.set(mode, key, rhs, opts)
    ::continue::
  end
end

-- Helper function for autocommand registration
function M.register_autocmds(group_name, autocmds)
  local group = vim.api.nvim_create_augroup(group_name, { clear = true })
  
  for _, autocmd in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(autocmd.event, {
      group = group,
      pattern = autocmd.pattern or "*",
      callback = autocmd.callback,
      command = autocmd.command,
      desc = autocmd.desc,
    })
  end
end

-- Helper function for option setting with validation
function M.set_options(options)
  for name, value in pairs(options) do
    local ok, _ = pcall(vim.api.nvim_set_option_value, name, value, {})
    if not ok then
      vim.notify(string.format("Failed to set option: %s", name), vim.log.levels.WARN)
    end
  end
end

-- Helper function for buffer-local option setting
function M.set_buffer_options(options)
  for name, value in pairs(options) do
    local ok, _ = pcall(vim.api.nvim_buf_set_option, 0, name, value)
    if not ok then
      vim.notify(string.format("Failed to set buffer option: %s", name), vim.log.levels.WARN)
    end
  end
end

-- Helper function for window-local option setting
function M.set_window_options(options)
  for name, value in pairs(options) do
    local ok, _ = pcall(vim.api.nvim_win_set_option, 0, name, value)
    if not ok then
      vim.notify(string.format("Failed to set window option: %s", name), vim.log.levels.WARN)
    end
  end
end

-- Helper function for environment-based plugin loading
function M.load_environment_plugins(env_plugins)
  local current_env = vim.env.YODA_ENV or "home"
  local plugins = {}
  
  for env, env_plugin_list in pairs(env_plugins) do
    if env == current_env or env == "all" then
      vim.list_extend(plugins, env_plugin_list)
    end
  end
  
  return plugins
end

-- Helper function for conditional plugin loading
function M.load_conditional_plugins(conditions)
  local plugins = {}
  
  for condition, plugin_list in pairs(conditions) do
    if type(condition) == "function" and condition() then
      vim.list_extend(plugins, plugin_list)
    elseif type(condition) == "string" and vim.fn.executable(condition) == 1 then
      vim.list_extend(plugins, plugin_list)
    elseif type(condition) == "boolean" and condition then
      vim.list_extend(plugins, plugin_list)
    end
  end
  
  return plugins
end

-- Helper function for plugin dependency management
function M.create_plugin_with_deps(plugin_spec, dependencies)
  if dependencies and #dependencies > 0 then
    plugin_spec.dependencies = plugin_spec.dependencies or {}
    vim.list_extend(plugin_spec.dependencies, dependencies)
  end
  return plugin_spec
end

-- Helper function for lazy loading configuration
function M.create_lazy_plugin(plugin_spec, lazy_opts)
  lazy_opts = lazy_opts or {}
  
  for key, value in pairs(lazy_opts) do
    plugin_spec[key] = value
  end
  
  return plugin_spec
end

-- Helper function for plugin configuration validation
function M.validate_plugin_spec(plugin_spec)
  local errors = {}
  
  if not plugin_spec[1] and not plugin_spec.dir then
    table.insert(errors, "Plugin spec must have a name or directory")
  end
  
  if plugin_spec.config and type(plugin_spec.config) ~= "function" then
    table.insert(errors, "Plugin config must be a function")
  end
  
  if plugin_spec.opts and type(plugin_spec.opts) ~= "table" and type(plugin_spec.opts) ~= "function" then
    table.insert(errors, "Plugin opts must be a table or function")
  end
  
  return #errors == 0, errors
end

-- Helper function for plugin performance optimization
function M.optimize_plugin_performance(plugin_spec)
  -- Set lazy loading by default
  if plugin_spec.lazy == nil then
    plugin_spec.lazy = true
  end
  
  -- Disable documentation generation for local plugins
  if plugin_spec.dir then
    plugin_spec.disable_docs = true
    plugin_spec.readme = false
    plugin_spec.doc = false
    plugin_spec.docs = false
  end
  
  return plugin_spec
end

return M 