#!/usr/bin/env nvim -l

-- Neogit Lag Analysis Script
-- This script analyzes what might be causing lag in Neogit commit message buffers

local M = {}

-- Function to get buffer info
local function get_buffer_info(bufnr)
  local info = {
    bufnr = bufnr,
    name = vim.api.nvim_buf_get_name(bufnr),
    filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr }),
    buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr }),
    modifiable = vim.api.nvim_get_option_value('modifiable', { buf = bufnr }),
    readonly = vim.api.nvim_get_option_value('readonly', { buf = bufnr }),
    swapfile = vim.api.nvim_get_option_value('swapfile', { buf = bufnr }),
    undofile = vim.api.nvim_get_option_value('undofile', { buf = bufnr }),
  }
  return info
end

-- Function to get all autocmds for a buffer
local function get_buffer_autocmds(bufnr)
  local events = {
    'TextChanged', 'TextChangedI', 'TextChangedP', 'TextChangedT',
    'CursorMoved', 'CursorMovedI', 'CursorHold', 'CursorHoldI',
    'InsertEnter', 'InsertLeave', 'InsertChange', 'InsertCharPre',
    'BufEnter', 'BufLeave', 'BufWritePre', 'BufWritePost',
    'FileType', 'CompleteChanged', 'CompleteDone'
  }
  
  local autocmds = {}
  for _, event in ipairs(events) do
    local cmds = vim.api.nvim_get_autocmds({
      buffer = bufnr,
      event = event
    })
    if #cmds > 0 then
      autocmds[event] = cmds
    end
  end
  
  return autocmds
end

-- Function to get LSP clients attached to buffer
local function get_lsp_clients(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local client_info = {}
  
  for _, client in ipairs(clients) do
    table.insert(client_info, {
      id = client.id,
      name = client.name,
      root_dir = client.config.root_dir,
      capabilities = {
        completion = client.server_capabilities.completionProvider ~= nil,
        hover = client.server_capabilities.hoverProvider ~= nil,
        signature_help = client.server_capabilities.signatureHelpProvider ~= nil,
        document_highlight = client.server_capabilities.documentHighlightProvider ~= nil,
        document_formatting = client.server_capabilities.documentFormattingProvider ~= nil,
        semantic_tokens = client.server_capabilities.semanticTokensProvider ~= nil,
      }
    })
  end
  
  return client_info
end

-- Function to get attached plugins/extensions
local function get_plugin_attachments(bufnr)
  local attachments = {}
  
  -- Check for common plugins that attach to buffers
  local plugins_to_check = {
    'cmp',
    'copilot',
    'gitsigns',
    'treesitter',
    'indent_blankline',
    'nvim-colorizer',
    'vim-illuminate',
    'trouble',
    'aerial',
    'symbols-outline',
    'lspsaga',
  }
  
  for _, plugin in ipairs(plugins_to_check) do
    local ok, _ = pcall(require, plugin)
    if ok then
      attachments[plugin] = true
    end
  end
  
  return attachments
end

-- Function to check for expensive operations
local function check_expensive_operations()
  local expensive_patterns = {}
  
  -- Check for file watchers
  local file_events = vim.api.nvim_get_autocmds({
    event = { 'FileChangedShell', 'FileChangedShellPost', 'BufWritePost' }
  })
  
  for _, autocmd in ipairs(file_events) do
    if autocmd.callback or (autocmd.command and autocmd.command:match('system') or autocmd.command:match('job')) then
      table.insert(expensive_patterns, {
        type = 'file_watcher',
        event = autocmd.event,
        group = autocmd.group_name,
        pattern = autocmd.pattern,
        command = autocmd.command
      })
    end
  end
  
  -- Check for text change handlers that might be expensive
  local text_events = vim.api.nvim_get_autocmds({
    event = { 'TextChanged', 'TextChangedI' }
  })
  
  for _, autocmd in ipairs(text_events) do
    table.insert(expensive_patterns, {
      type = 'text_change_handler',
      event = autocmd.event,
      group = autocmd.group_name,
      pattern = autocmd.pattern,
      command = autocmd.command,
      buffer = autocmd.buffer
    })
  end
  
  return expensive_patterns
end

-- Function to analyze specific Neogit patterns
local function analyze_neogit_specific()
  local analysis = {}
  
  -- Check for commit message specific patterns
  local commit_autocmds = vim.api.nvim_get_autocmds({
    pattern = { "COMMIT_EDITMSG", "*.git/COMMIT_EDITMSG", "*/COMMIT_EDITMSG" }
  })
  
  analysis.commit_specific_autocmds = commit_autocmds
  
  -- Check for git-related autocmds
  local git_autocmds = vim.api.nvim_get_autocmds({
    pattern = { "*.git/*", ".git/*", "*/git/*" }
  })
  
  analysis.git_related_autocmds = git_autocmds
  
  -- Check for gitcommit filetype autocmds
  local gitcommit_autocmds = vim.api.nvim_get_autocmds({
    event = 'FileType',
    pattern = 'gitcommit'
  })
  
  analysis.gitcommit_filetype_autocmds = gitcommit_autocmds
  
  return analysis
end

-- Main analysis function
function M.analyze_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  
  print("=== Neogit Lag Analysis for Buffer " .. bufnr .. " ===\n")
  
  -- Basic buffer info
  local buffer_info = get_buffer_info(bufnr)
  print("Buffer Info:")
  for k, v in pairs(buffer_info) do
    print("  " .. k .. ": " .. tostring(v))
  end
  print()
  
  -- LSP clients
  local lsp_clients = get_lsp_clients(bufnr)
  print("LSP Clients (" .. #lsp_clients .. "):")
  for _, client in ipairs(lsp_clients) do
    print("  " .. client.name .. " (ID: " .. client.id .. ")")
    print("    Root: " .. (client.root_dir or "none"))
    print("    Capabilities:")
    for cap, enabled in pairs(client.capabilities) do
      if enabled then
        print("      " .. cap .. ": enabled")
      end
    end
  end
  print()
  
  -- Autocmds
  local autocmds = get_buffer_autocmds(bufnr)
  print("Buffer Autocmds:")
  for event, cmds in pairs(autocmds) do
    print("  " .. event .. " (" .. #cmds .. " handlers):")
    for _, cmd in ipairs(cmds) do
      print("    Group: " .. (cmd.group_name or "none"))
      print("    Pattern: " .. (cmd.pattern or "none"))
      if cmd.command then
        print("    Command: " .. cmd.command)
      elseif cmd.callback then
        print("    Callback: function")
      end
      print("    ---")
    end
  end
  print()
  
  -- Plugin attachments
  local plugins = get_plugin_attachments(bufnr)
  print("Detected Plugins:")
  for plugin, _ in pairs(plugins) do
    print("  " .. plugin)
  end
  print()
  
  -- Expensive operations
  local expensive = check_expensive_operations()
  print("Potentially Expensive Operations (" .. #expensive .. "):")
  for _, op in ipairs(expensive) do
    print("  Type: " .. op.type)
    print("  Event: " .. op.event)
    print("  Group: " .. (op.group or "none"))
    if op.command then
      print("  Command: " .. op.command)
    end
    print("  ---")
  end
  print()
  
  -- Neogit specific analysis
  local neogit_analysis = analyze_neogit_specific()
  print("Neogit Specific Analysis:")
  print("  Commit-specific autocmds: " .. #neogit_analysis.commit_specific_autocmds)
  print("  Git-related autocmds: " .. #neogit_analysis.git_related_autocmds)
  print("  Gitcommit filetype autocmds: " .. #neogit_analysis.gitcommit_filetype_autocmds)
  
  if #neogit_analysis.gitcommit_filetype_autocmds > 0 then
    print("\n  Gitcommit FileType handlers:")
    for _, cmd in ipairs(neogit_analysis.gitcommit_filetype_autocmds) do
      print("    Group: " .. (cmd.group_name or "none"))
      if cmd.command then
        print("    Command: " .. cmd.command)
      elseif cmd.callback then
        print("    Callback: function")
      end
      print("    ---")
    end
  end
end

-- Function to profile text input performance
function M.profile_text_input(duration)
  duration = duration or 5000 -- 5 seconds default
  
  print("=== Starting Text Input Profiling ===")
  print("Type in the buffer for " .. (duration/1000) .. " seconds...")
  print("Profiling will start in 3 seconds...")
  
  vim.defer_fn(function()
    print("Profiling started! Type some text...")
    vim.cmd("profile start neogit_profile.log")
    vim.cmd("profile func *")
    vim.cmd("profile file *")
    
    vim.defer_fn(function()
      vim.cmd("profile pause")
      print("Profiling complete! Check neogit_profile.log")
    end, duration)
  end, 3000)
end

-- Function to create a user command for easy access
function M.setup_commands()
  vim.api.nvim_create_user_command('AnalyzeNeogitLag', function()
    M.analyze_current_buffer()
  end, { desc = 'Analyze current buffer for Neogit lag issues' })
  
  vim.api.nvim_create_user_command('ProfileNeogitInput', function(opts)
    local duration = tonumber(opts.args) or 5000
    M.profile_text_input(duration)
  end, { 
    desc = 'Profile text input performance',
    nargs = '?'
  })
end

-- Auto-setup commands when this module is loaded
M.setup_commands()

return M