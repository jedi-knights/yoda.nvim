-- lua/yoda/utils/plugin.lua
-- Plugin configuration utilities

local M = {}

-- Standard plugin options
M.opts = {
  noremap = true,
  silent = true,
}

-- Create a simple plugin spec with basic setup
function M.simple_plugin(name, opts)
  opts = opts or {}
  local plugin_spec = {
    name,
    lazy = opts.lazy,
    event = opts.event,
    cmd = opts.cmd,
    ft = opts.ft,
    dependencies = opts.dependencies,
  }
  
  -- Only add config if it's provided
  if opts.config then
    plugin_spec.config = opts.config
  end
  
  return plugin_spec
end

-- Create a plugin spec with custom config function
function M.plugin_with_config(name, config_fn, opts)
  opts = opts or {}
  return {
    name,
    lazy = opts.lazy,
    event = opts.event,
    cmd = opts.cmd,
    ft = opts.ft,
    dependencies = opts.dependencies,
    config = config_fn,
  }
end

-- Create a keymap plugin spec
function M.keymap_plugin(name, keys, opts)
  opts = opts or {}
  return {
    name,
    keys = keys,
    lazy = opts.lazy,
    event = opts.event,
    cmd = opts.cmd,
    ft = opts.ft,
    dependencies = opts.dependencies,
    config = opts.config,
  }
end

-- Standard keymap options
function M.keymap_opts(desc)
  return {
    noremap = true,
    silent = true,
    desc = desc,
  }
end

-- Create a function keymap
function M.fn_keymap(mode, lhs, fn, desc)
  return {
    mode,
    lhs,
    fn,
    M.keymap_opts(desc),
  }
end

-- Create a command keymap
function M.cmd_keymap(mode, lhs, cmd, desc)
  return {
    mode,
    lhs,
    "<cmd>" .. cmd .. "<cr>",
    M.keymap_opts(desc),
  }
end

return M 