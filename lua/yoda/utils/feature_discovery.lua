-- lua/yoda/utils/feature_discovery.lua
-- Feature discovery and tutorial suggestion system for Yoda.nvim

local M = {}

-- Feature discovery data
local discovery_data = {
  user_actions = {},
  feature_usage = {},
  suggestions = {},
  discovery_events = {},
  last_suggestion_time = 0
}

-- Feature categories
local FEATURE_CATEGORIES = {
  NAVIGATION = "navigation",
  AI = "ai",
  DEVELOPMENT = "development",
  PERFORMANCE = "performance",
  TROUBLESHOOTING = "troubleshooting",
  ADVANCED = "advanced"
}

-- Feature definitions with triggers and suggestions
local FEATURES = {
  -- Navigation features
  file_finder = {
    name = "File Finder",
    category = FEATURE_CATEGORIES.NAVIGATION,
    keymap = "<leader>ff",
    description = "Find files with Telescope",
    tutorial = "welcome",
    help_topic = "navigation",
    usage_threshold = 1,
    suggestion_delay = 300 -- seconds
  },
  file_search = {
    name = "File Search",
    category = FEATURE_CATEGORIES.NAVIGATION,
    keymap = "<leader>fg",
    description = "Search in files with Telescope",
    tutorial = "welcome",
    help_topic = "navigation",
    usage_threshold = 2,
    suggestion_delay = 600
  },
  file_explorer = {
    name = "File Explorer",
    category = FEATURE_CATEGORIES.NAVIGATION,
    keymap = "<leader>e",
    description = "Open file explorer",
    tutorial = "welcome",
    help_topic = "navigation",
    usage_threshold = 1,
    suggestion_delay = 300
  },
  
  -- AI features
  ai_chat = {
    name = "AI Chat",
    category = FEATURE_CATEGORIES.AI,
    keymap = "<leader>ac",
    description = "Open AI chat",
    tutorial = "ai_features",
    help_topic = "ai_features",
    usage_threshold = 1,
    suggestion_delay = 900
  },
  ai_ask = {
    name = "AI Ask",
    category = FEATURE_CATEGORIES.AI,
    keymap = "<leader>aa",
    description = "Ask AI questions",
    tutorial = "ai_features",
    help_topic = "ai_features",
    usage_threshold = 1,
    suggestion_delay = 900
  },
  copilot = {
    name = "GitHub Copilot",
    category = FEATURE_CATEGORIES.AI,
    keymap = "<leader>cp",
    description = "Toggle GitHub Copilot",
    tutorial = "ai_features",
    help_topic = "ai_features",
    usage_threshold = 1,
    suggestion_delay = 1200
  },
  
  -- Development features
  lsp_definition = {
    name = "LSP Go to Definition",
    category = FEATURE_CATEGORIES.DEVELOPMENT,
    keymap = "<leader>ld",
    description = "Go to definition with LSP",
    tutorial = "development",
    help_topic = "development",
    usage_threshold = 3,
    suggestion_delay = 1800
  },
  testing = {
    name = "Testing",
    category = FEATURE_CATEGORIES.DEVELOPMENT,
    keymap = "<leader>tn",
    description = "Run tests",
    tutorial = "development",
    help_topic = "development",
    usage_threshold = 2,
    suggestion_delay = 1500
  },
  terminal = {
    name = "Terminal",
    category = FEATURE_CATEGORIES.DEVELOPMENT,
    keymap = "<leader>vt",
    description = "Open terminal",
    tutorial = "development",
    help_topic = "development",
    usage_threshold = 1,
    suggestion_delay = 600
  },
  
  -- Performance features
  profiling = {
    name = "Startup Profiling",
    category = FEATURE_CATEGORIES.PERFORMANCE,
    command = "YodaProfilingOn",
    description = "Enable startup profiling",
    tutorial = "performance",
    help_topic = "performance",
    usage_threshold = 1,
    suggestion_delay = 2400
  },
  optimization = {
    name = "Performance Optimization",
    category = FEATURE_CATEGORIES.PERFORMANCE,
    command = "YodaStartupOptimize",
    description = "Get optimization suggestions",
    tutorial = "performance",
    help_topic = "performance",
    usage_threshold = 1,
    suggestion_delay = 2400
  },
  
  -- Troubleshooting features
  error_recovery = {
    name = "Error Recovery",
    category = FEATURE_CATEGORIES.TROUBLESHOOTING,
    command = "YodaErrorReport",
    description = "View error recovery report",
    tutorial = "error_recovery",
    help_topic = "troubleshooting",
    usage_threshold = 1,
    suggestion_delay = 3000
  },
  plugin_health = {
    name = "Plugin Health",
    category = FEATURE_CATEGORIES.TROUBLESHOOTING,
    command = "YodaPluginHealth",
    description = "Check plugin health",
    tutorial = "error_recovery",
    help_topic = "troubleshooting",
    usage_threshold = 1,
    suggestion_delay = 3000
  }
}

-- Track user action
function M.track_action(action_type, action_data)
  local timestamp = os.time()
  
  -- Record the action
  table.insert(discovery_data.user_actions, {
    type = action_type,
    data = action_data,
    timestamp = timestamp
  })
  
  -- Update feature usage
  M.update_feature_usage(action_type, action_data)
  
  -- Check for discovery events
  M.check_discovery_events(action_type, action_data)
end

-- Update feature usage statistics
function M.update_feature_usage(action_type, action_data)
  for feature_id, feature in pairs(FEATURES) do
    local is_used = false
    
    if action_type == "keymap" and feature.keymap then
      if action_data == feature.keymap then
        is_used = true
      end
    elseif action_type == "command" and feature.command then
      if action_data == feature.command then
        is_used = true
      end
    end
    
    if is_used then
      discovery_data.feature_usage[feature_id] = discovery_data.feature_usage[feature_id] or 0
      discovery_data.feature_usage[feature_id] = discovery_data.feature_usage[feature_id] + 1
    end
  end
end

-- Check for discovery events
function M.check_discovery_events(action_type, action_data)
  local current_time = os.time()
  
  for feature_id, feature in pairs(FEATURES) do
    local usage_count = discovery_data.feature_usage[feature_id] or 0
    
    -- Check if feature has reached usage threshold
    if usage_count == feature.usage_threshold then
      -- Check if enough time has passed since last suggestion
      local time_since_last = current_time - discovery_data.last_suggestion_time
      if time_since_last >= feature.suggestion_delay then
        M.suggest_feature(feature_id, feature)
        discovery_data.last_suggestion_time = current_time
      end
    end
  end
end

-- Suggest a feature to the user
function M.suggest_feature(feature_id, feature)
  local message = string.format("🎯 You've used '%s' %d times! Would you like to learn more about it?", 
    feature.name, discovery_data.feature_usage[feature_id])
  
  -- Create suggestion with options
  local suggestion = {
    feature_id = feature_id,
    feature = feature,
    message = message,
    timestamp = os.time()
  }
  
  table.insert(discovery_data.suggestions, suggestion)
  
  -- Show notification with options
  vim.notify(message, vim.log.levels.INFO, {
    title = "Yoda Feature Discovery",
    timeout = 8000,
    actions = {
      {
        name = "Learn More",
        callback = function()
          M.show_feature_help(feature_id, feature)
        end
      },
      {
        name = "Start Tutorial",
        callback = function()
          M.start_feature_tutorial(feature_id, feature)
        end
      },
      {
        name = "Dismiss",
        callback = function()
          -- Just dismiss
        end
      }
    }
  })
end

-- Show feature help
function M.show_feature_help(feature_id, feature)
  local help_system = require("yoda.utils.interactive_help")
  if help_system and help_system.show_help_topic then
    help_system.show_help_topic(feature.help_topic)
  else
    -- Fallback: show basic help
    local help_message = string.format([[
Feature: %s
Category: %s
Description: %s

Keymap: %s
Command: %s

Tutorial: %s
Help Topic: %s
]], 
      feature.name,
      feature.category,
      feature.description,
      feature.keymap or "N/A",
      feature.command or "N/A",
      feature.tutorial or "N/A",
      feature.help_topic or "N/A"
    )
    
    vim.notify(help_message, vim.log.levels.INFO, {
      title = "Yoda Feature Help",
      timeout = 10000
    })
  end
end

-- Start feature tutorial
function M.start_feature_tutorial(feature_id, feature)
  local help_system = require("yoda.utils.interactive_help")
  if help_system and help_system.start_tutorial then
    help_system.start_tutorial(feature.tutorial)
  else
    vim.notify("Tutorial system not available", vim.log.levels.WARN)
  end
end

-- Get feature usage statistics
function M.get_feature_stats()
  local stats = {
    total_features = #vim.tbl_keys(FEATURES),
    used_features = 0,
    unused_features = 0,
    most_used = {},
    category_usage = {}
  }
  
  -- Count used features
  for feature_id, usage_count in pairs(discovery_data.feature_usage) do
    if usage_count > 0 then
      stats.used_features = stats.used_features + 1
      table.insert(stats.most_used, {
        feature_id = feature_id,
        name = FEATURES[feature_id].name,
        usage_count = usage_count,
        category = FEATURES[feature_id].category
      })
    end
  end
  
  stats.unused_features = stats.total_features - stats.used_features
  
  -- Sort by usage count
  table.sort(stats.most_used, function(a, b)
    return a.usage_count > b.usage_count
  end)
  
  -- Calculate category usage
  for _, feature_usage in ipairs(stats.most_used) do
    local category = feature_usage.category
    stats.category_usage[category] = stats.category_usage[category] or 0
    stats.category_usage[category] = stats.category_usage[category] + feature_usage.usage_count
  end
  
  return stats
end

-- Print feature discovery report
function M.print_discovery_report()
  local stats = M.get_feature_stats()
  
  print("=== Yoda.nvim Feature Discovery Report ===")
  print(string.format("Total Features: %d", stats.total_features))
  print(string.format("Used Features: %d", stats.used_features))
  print(string.format("Unused Features: %d", stats.unused_features))
  print(string.format("Usage Rate: %.1f%%", (stats.used_features / stats.total_features) * 100))
  
  if #stats.most_used > 0 then
    print("\n🔥 Most Used Features:")
    for i, feature in ipairs(stats.most_used) do
      if i <= 5 then -- Show top 5
        print(string.format("  %d. %s (%s): %d uses", 
          i, feature.name, feature.category, feature.usage_count))
      end
    end
  end
  
  if #vim.tbl_keys(stats.category_usage) > 0 then
    print("\n📊 Usage by Category:")
    for category, usage in pairs(stats.category_usage) do
      print(string.format("  %s: %d uses", category, usage))
    end
  end
  
  -- Suggest unused features
  local unused_features = {}
  for feature_id, feature in pairs(FEATURES) do
    local usage_count = discovery_data.feature_usage[feature_id] or 0
    if usage_count == 0 then
      table.insert(unused_features, {
        id = feature_id,
        name = feature.name,
        category = feature.category,
        description = feature.description
      })
    end
  end
  
  if #unused_features > 0 then
    print("\n💡 Suggested Features to Try:")
    for i, feature in ipairs(unused_features) do
      if i <= 3 then -- Show top 3 suggestions
        print(string.format("  %s (%s): %s", 
          feature.name, feature.category, feature.description))
      end
    end
  end
  
  print("==========================================")
end

-- Reset feature discovery data
function M.reset_discovery_data()
  discovery_data.user_actions = {}
  discovery_data.feature_usage = {}
  discovery_data.suggestions = {}
  discovery_data.discovery_events = {}
  discovery_data.last_suggestion_time = 0
  
  vim.notify("Feature discovery data reset", vim.log.levels.INFO, {
    title = "Yoda Feature Discovery",
    timeout = 2000
  })
end

-- Get personalized recommendations
function M.get_recommendations()
  local stats = M.get_feature_stats()
  local recommendations = {}
  
  -- Find unused features in categories the user uses
  local used_categories = {}
  for _, feature_usage in ipairs(stats.most_used) do
    used_categories[feature_usage.category] = true
  end
  
  for feature_id, feature in pairs(FEATURES) do
    local usage_count = discovery_data.feature_usage[feature_id] or 0
    if usage_count == 0 and used_categories[feature.category] then
      table.insert(recommendations, {
        type = "unused_in_category",
        feature = feature,
        reason = string.format("You use other %s features, try this one", feature.category)
      })
    end
  end
  
  -- Find advanced features for experienced users
  local total_usage = 0
  for _, count in pairs(discovery_data.feature_usage) do
    total_usage = total_usage + count
  end
  
  if total_usage > 10 then
    for feature_id, feature in pairs(FEATURES) do
      local usage_count = discovery_data.feature_usage[feature_id] or 0
      if usage_count == 0 and feature.category == FEATURE_CATEGORIES.ADVANCED then
        table.insert(recommendations, {
          type = "advanced_feature",
          feature = feature,
          reason = "You're an experienced user, try this advanced feature"
        })
      end
    end
  end
  
  return recommendations
end

-- Show personalized recommendations
function M.show_recommendations()
  local recommendations = M.get_recommendations()
  
  if #recommendations == 0 then
    vim.notify("No new recommendations at this time", vim.log.levels.INFO, {
      title = "Yoda Recommendations",
      timeout = 3000
    })
    return
  end
  
  -- Create recommendation window
  local width = math.min(70, vim.o.columns - 4)
  local height = math.min(15, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
    title = " Yoda Recommendations ",
    title_pos = "center"
  })
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  
  -- Add recommendations
  local lines = {"Personalized Recommendations:", ""}
  for i, rec in ipairs(recommendations) do
    table.insert(lines, string.format("%d. %s", i, rec.feature.name))
    table.insert(lines, string.format("   %s", rec.feature.description))
    table.insert(lines, string.format("   💡 %s", rec.reason))
    table.insert(lines, "")
  end
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Add keymaps for selection
  for i, rec in ipairs(recommendations) do
    vim.keymap.set("n", tostring(i), function()
      vim.api.nvim_win_close(win, true)
      M.show_feature_help(rec.feature.id, rec.feature)
    end, { buffer = buf, noremap = true })
  end
  
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true })
end

-- User commands
vim.api.nvim_create_user_command("YodaDiscoveryReport", function()
  M.print_discovery_report()
end, { desc = "Show feature discovery report" })

vim.api.nvim_create_user_command("YodaRecommendations", function()
  M.show_recommendations()
end, { desc = "Show personalized recommendations" })

vim.api.nvim_create_user_command("YodaResetDiscovery", function()
  M.reset_discovery_data()
end, { desc = "Reset feature discovery data" })

-- Track keymap usage
vim.api.nvim_create_autocmd("User", {
  pattern = "YodaKeymapUsed",
  callback = function(event)
    M.track_action("keymap", event.data)
  end
})

-- Track command usage
vim.api.nvim_create_autocmd("User", {
  pattern = "YodaCommandUsed", 
  callback = function(event)
    M.track_action("command", event.data)
  end
})

return M 