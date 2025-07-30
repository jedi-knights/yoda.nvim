-- lua/yoda/utils/interactive_help.lua
-- Interactive tutorial and help system for Yoda.nvim

local M = {}

-- Help system data
local help_data = {
  tutorials = {},
  help_topics = {},
  user_progress = {},
  current_tutorial = nil,
  tutorial_state = {}
}

-- Tutorial categories
local TUTORIAL_CATEGORIES = {
  BEGINNER = "beginner",
  INTERMEDIATE = "intermediate",
  ADVANCED = "advanced",
  FEATURE = "feature",
  TROUBLESHOOTING = "troubleshooting"
}

-- Tutorial states
local TUTORIAL_STATES = {
  NOT_STARTED = "not_started",
  IN_PROGRESS = "in_progress",
  COMPLETED = "completed",
  SKIPPED = "skipped"
}

-- Define tutorials
local TUTORIALS = {
  {
    id = "welcome",
    title = "Welcome to Yoda.nvim",
    category = TUTORIAL_CATEGORIES.BEGINNER,
    description = "Get started with your new Neovim distribution",
    steps = {
      {
        title = "Welcome!",
        content = "Welcome to Yoda.nvim! This interactive tutorial will help you get started with your new Neovim distribution.",
        action = "info",
        keymap = nil
      },
      {
        title = "Environment Detection",
        content = "Yoda automatically detects your environment (Home/Work) and adjusts features accordingly. You should see a notification about this.",
        action = "check_notification",
        keymap = nil
      },
      {
        title = "Basic Navigation",
        content = "Let's start with basic navigation. Try using <leader>ff to find files.",
        action = "try_keymap",
        keymap = "<leader>ff",
        hint = "Press <leader>ff to open file finder"
      },
      {
        title = "File Explorer",
        content = "Open the file explorer with <leader>e",
        action = "try_keymap",
        keymap = "<leader>e",
        hint = "Press <leader>e to open file explorer"
      },
      {
        title = "Telescope",
        content = "Telescope is your fuzzy finder. Try <leader>fg to search for text in files.",
        action = "try_keymap",
        keymap = "<leader>fg",
        hint = "Press <leader>fg to search in files"
      }
    }
  },
  {
    id = "ai_features",
    title = "AI Features",
    category = TUTORIAL_CATEGORIES.FEATURE,
    description = "Learn how to use AI-powered features",
    steps = {
      {
        title = "AI Chat",
        content = "Open AI chat with <leader>ac",
        action = "try_keymap",
        keymap = "<leader>ac",
        hint = "Press <leader>ac to open AI chat"
      },
      {
        title = "AI Ask",
        content = "Ask AI questions with <leader>aa",
        action = "try_keymap",
        keymap = "<leader>aa",
        hint = "Press <leader>aa to ask AI"
      },
      {
        title = "Copilot",
        content = "Toggle GitHub Copilot with <leader>cp",
        action = "try_keymap",
        keymap = "<leader>cp",
        hint = "Press <leader>cp to toggle Copilot"
      }
    }
  },
  {
    id = "development",
    title = "Development Tools",
    category = TUTORIAL_CATEGORIES.INTERMEDIATE,
    description = "Learn about development and debugging tools",
    steps = {
      {
        title = "LSP Features",
        content = "Use LSP features like go to definition with <leader>ld",
        action = "try_keymap",
        keymap = "<leader>ld",
        hint = "Press <leader>ld to go to definition"
      },
      {
        title = "Testing",
        content = "Run tests with <leader>tn for nearest test",
        action = "try_keymap",
        keymap = "<leader>tn",
        hint = "Press <leader>tn to run nearest test"
      },
      {
        title = "Terminal",
        content = "Open terminal with <leader>vt",
        action = "try_keymap",
        keymap = "<leader>vt",
        hint = "Press <leader>vt to open terminal"
      },
      {
        title = "Debugging",
        content = "Debug tests with <leader>td",
        action = "try_keymap",
        keymap = "<leader>td",
        hint = "Press <leader>td to debug test"
      }
    }
  },
  {
    id = "performance",
    title = "Performance & Profiling",
    category = TUTORIAL_CATEGORIES.ADVANCED,
    description = "Learn about performance monitoring and optimization",
    steps = {
      {
        title = "Startup Profiling",
        content = "Enable startup profiling with :YodaProfilingOn",
        action = "try_command",
        command = "YodaProfilingOn",
        hint = "Type :YodaProfilingOn and press Enter"
      },
      {
        title = "Performance Report",
        content = "View performance report with :YodaStartupProfile",
        action = "try_command",
        command = "YodaStartupProfile",
        hint = "Type :YodaStartupProfile and press Enter"
      },
      {
        title = "Optimization",
        content = "Get optimization suggestions with :YodaStartupOptimize",
        action = "try_command",
        command = "YodaStartupOptimize",
        hint = "Type :YodaStartupOptimize and press Enter"
      }
    }
  },
  {
    id = "error_recovery",
    title = "Error Recovery",
    category = TUTORIAL_CATEGORIES.TROUBLESHOOTING,
    description = "Learn how to handle errors and recover from issues",
    steps = {
      {
        title = "Error Report",
        content = "View error report with :YodaErrorReport",
        action = "try_command",
        command = "YodaErrorReport",
        hint = "Type :YodaErrorReport and press Enter"
      },
      {
        title = "Plugin Health",
        content = "Check plugin health with :YodaPluginHealth",
        action = "try_command",
        command = "YodaPluginHealth",
        hint = "Type :YodaPluginHealth and press Enter"
      },
      {
        title = "Auto Recovery",
        content = "Run automatic recovery with :YodaAutoRecovery",
        action = "try_command",
        command = "YodaAutoRecovery",
        hint = "Type :YodaAutoRecovery and press Enter"
      }
    }
  }
}

-- Help topics
local HELP_TOPICS = {
  navigation = {
    title = "Navigation",
    content = [[
# Navigation in Yoda.nvim

## File Finding
- `<leader>ff` - Find files with Telescope
- `<leader>fg` - Search in files with Telescope
- `<leader>e` - Open file explorer

## Window Management
- `<leader>|` - Vertical split
- `<leader>-` - Horizontal split
- `<leader>se` - Equalize window sizes

## Buffer Navigation
- `<leader>bb` - Switch buffers
- `<leader>bd` - Delete buffer
]],
    category = "basic"
  },
  ai_features = {
    title = "AI Features",
    content = [[
# AI Features

## Avante AI
- `<leader>aa` - Ask Avante AI
- `<leader>ac` - Open AI chat
- `<leader>am` - Open MCP Hub

## GitHub Copilot
- `<leader>cp` - Toggle Copilot
- `<C-j>` - Accept Copilot suggestion
- `<C-k>` - Dismiss Copilot suggestion

## Mercury (Work Environment)
- `<leader>m` - Open Mercury
- `<leader>ma` - Open Mercury Agentic Panel
]],
    category = "ai"
  },
  development = {
    title = "Development Tools",
    content = [[
# Development Tools

## LSP Features
- `<leader>ld` - Go to definition
- `<leader>lr` - Find references
- `<leader>la` - Code actions
- `<leader>lf` - Format buffer

## Testing
- `<leader>tn` - Run nearest test
- `<leader>tf` - Run tests in file
- `<leader>ta` - Run all tests
- `<leader>td` - Debug test

## Terminal
- `<leader>vt` - Open terminal
- `<leader>vr` - Open Python REPL
]],
    category = "development"
  },
  performance = {
    title = "Performance & Profiling",
    content = [[
# Performance & Profiling

## Startup Profiling
- `:YodaProfilingOn` - Enable profiling
- `:YodaProfilingOff` - Disable profiling
- `:YodaStartupProfile` - View startup report
- `:YodaStartupOptimize` - Get optimization suggestions

## Configuration
- `:YodaShowConfig` - Show current configuration
- `:YodaOptimizeConfig` - Analyze configuration
- `:YodaApplyOptimizations` - Apply optimizations
]],
    category = "advanced"
  },
  troubleshooting = {
    title = "Troubleshooting",
    content = [[
# Troubleshooting

## Error Recovery
- `:YodaErrorReport` - View error report
- `:YodaClearErrors` - Clear error history
- `:YodaAutoRecovery` - Run automatic recovery

## Plugin Health
- `:YodaPluginHealth` - Check plugin health
- `:YodaRecoverPlugins` - Recover failed plugins
- `:YodaPluginStats` - View plugin statistics

## Keymap Debugging
- `:YodaKeymapDump` - Dump all keymaps
- `:YodaKeymapConflicts` - Find keymap conflicts
- `:YodaLoggedKeymaps` - View logged keymaps
]],
    category = "troubleshooting"
  }
}

-- Initialize help system
function M.init()
  -- Load tutorials
  for _, tutorial in ipairs(TUTORIALS) do
    help_data.tutorials[tutorial.id] = tutorial
  end
  
  -- Load help topics
  for topic_id, topic in pairs(HELP_TOPICS) do
    help_data.help_topics[topic_id] = topic
  end
  
  -- Load user progress
  M.load_user_progress()
end

-- Load user progress from persistent storage
function M.load_user_progress()
  local progress_file = vim.fn.stdpath("data") .. "/yoda_tutorial_progress.json"
  
  local ok, content = pcall(vim.fn.readfile, progress_file)
  if ok and content and #content > 0 then
    local json_content = table.concat(content, "\n")
    local success, progress = pcall(vim.json.decode, json_content)
    if success and progress then
      help_data.user_progress = progress
    end
  end
end

-- Save user progress to persistent storage
function M.save_user_progress()
  local progress_file = vim.fn.stdpath("data") .. "/yoda_tutorial_progress.json"
  local json_content = vim.json.encode(help_data.user_progress)
  
  vim.fn.writefile(vim.split(json_content, "\n"), progress_file)
end

-- Start a tutorial
function M.start_tutorial(tutorial_id)
  local tutorial = help_data.tutorials[tutorial_id]
  if not tutorial then
    vim.notify("Tutorial not found: " .. tutorial_id, vim.log.levels.ERROR)
    return
  end
  
  help_data.current_tutorial = tutorial_id
  help_data.tutorial_state = {
    current_step = 1,
    total_steps = #tutorial.steps,
    completed_steps = {}
  }
  
  -- Mark tutorial as in progress
  help_data.user_progress[tutorial_id] = TUTORIAL_STATES.IN_PROGRESS
  
  M.show_tutorial_step(1)
end

-- Show tutorial step
function M.show_tutorial_step(step_number)
  local tutorial = help_data.tutorials[help_data.current_tutorial]
  if not tutorial then
    return
  end
  
  local step = tutorial.steps[step_number]
  if not step then
    M.complete_tutorial()
    return
  end
  
  help_data.tutorial_state.current_step = step_number
  
  -- Create notification with step information
  local message = string.format("Tutorial: %s\nStep %d/%d: %s\n\n%s", 
    tutorial.title, step_number, #tutorial.steps, step.title, step.content)
  
  if step.hint then
    message = message .. "\n\n💡 " .. step.hint
  end
  
  -- Show step notification
  vim.notify(message, vim.log.levels.INFO, {
    title = "Yoda Tutorial",
    timeout = 10000,
    on_close = function()
      -- Handle step completion
      M.handle_step_completion(step_number, step)
    end
  })
end

-- Handle step completion
function M.handle_step_completion(step_number, step)
  if step.action == "try_keymap" then
    -- Wait for user to try the keymap
    vim.defer_fn(function()
      M.show_tutorial_step(step_number + 1)
    end, 3000)
  elseif step.action == "try_command" then
    -- Wait for user to try the command
    vim.defer_fn(function()
      M.show_tutorial_step(step_number + 1)
    end, 3000)
  elseif step.action == "check_notification" then
    -- Check if notification was shown
    vim.defer_fn(function()
      M.show_tutorial_step(step_number + 1)
    end, 2000)
  else
    -- Info step, continue immediately
    vim.defer_fn(function()
      M.show_tutorial_step(step_number + 1)
    end, 2000)
  end
end

-- Complete tutorial
function M.complete_tutorial()
  local tutorial_id = help_data.current_tutorial
  help_data.user_progress[tutorial_id] = TUTORIAL_STATES.COMPLETED
  M.save_user_progress()
  
  vim.notify("🎉 Tutorial completed: " .. help_data.tutorials[tutorial_id].title, 
    vim.log.levels.INFO, {
      title = "Yoda Tutorial",
      timeout = 5000
    })
  
  help_data.current_tutorial = nil
  help_data.tutorial_state = {}
end

-- Show help topic
function M.show_help_topic(topic_id)
  local topic = help_data.help_topics[topic_id]
  if not topic then
    vim.notify("Help topic not found: " .. topic_id, vim.log.levels.ERROR)
    return
  end
  
  -- Create a floating window with help content
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(20, vim.o.lines - 4)
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
    title = " Yoda Help: " .. topic.title .. " ",
    title_pos = "center"
  })
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  
  -- Add content
  local lines = vim.split(topic.content, "\n")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Add keymaps
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true })
  
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true })
end

-- Show tutorial list
function M.show_tutorial_list()
  local tutorials = {}
  for _, tutorial in ipairs(TUTORIALS) do
    local progress = help_data.user_progress[tutorial.id] or TUTORIAL_STATES.NOT_STARTED
    local status_icon = {
      [TUTORIAL_STATES.NOT_STARTED] = "⭕",
      [TUTORIAL_STATES.IN_PROGRESS] = "🔄",
      [TUTORIAL_STATES.COMPLETED] = "✅",
      [TUTORIAL_STATES.SKIPPED] = "⏭️"
    }
    
    table.insert(tutorials, {
      id = tutorial.id,
      title = tutorial.title,
      description = tutorial.description,
      category = tutorial.category,
      status = progress,
      status_icon = status_icon[progress]
    })
  end
  
  -- Create floating window with tutorial list
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
    title = " Yoda Tutorials ",
    title_pos = "center"
  })
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  
  -- Add tutorial list
  local lines = {"Available Tutorials:", ""}
  for i, tutorial in ipairs(tutorials) do
    table.insert(lines, string.format("%d. %s", i, tutorial.status_icon, tutorial.title))
    table.insert(lines, string.format("   %s", tutorial.description))
    table.insert(lines, "")
  end
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Add keymaps for selection
  for i, tutorial in ipairs(tutorials) do
    vim.keymap.set("n", tostring(i), function()
      vim.api.nvim_win_close(win, true)
      M.start_tutorial(tutorial.id)
    end, { buffer = buf, noremap = true })
  end
  
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true })
end

-- Show help topic list
function M.show_help_list()
  local topics = {}
  for topic_id, topic in pairs(help_data.help_topics) do
    table.insert(topics, {
      id = topic_id,
      title = topic.title,
      category = topic.category
    })
  end
  
  -- Sort by category
  table.sort(topics, function(a, b)
    return a.category < b.category
  end)
  
  -- Create floating window with help list
  local width = math.min(60, vim.o.columns - 4)
  local height = math.min(12, vim.o.lines - 4)
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
    title = " Yoda Help Topics ",
    title_pos = "center"
  })
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  
  -- Add help list
  local lines = {"Help Topics:", ""}
  for i, topic in ipairs(topics) do
    table.insert(lines, string.format("%d. %s", i, topic.title))
  end
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Add keymaps for selection
  for i, topic in ipairs(topics) do
    vim.keymap.set("n", tostring(i), function()
      vim.api.nvim_win_close(win, true)
      M.show_help_topic(topic.id)
    end, { buffer = buf, noremap = true })
  end
  
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true })
end

-- Contextual help based on current mode or action
function M.show_contextual_help()
  local mode = vim.fn.mode()
  local filetype = vim.bo.filetype
  local help_topic = nil
  
  -- Determine help topic based on context
  if mode == "n" then
    help_topic = "navigation"
  elseif filetype == "lua" then
    help_topic = "development"
  elseif vim.g.yoda_config and vim.g.yoda_config.enable_startup_profiling then
    help_topic = "performance"
  else
    help_topic = "navigation"
  end
  
  M.show_help_topic(help_topic)
end

-- User commands
vim.api.nvim_create_user_command("YodaTutorials", function()
  M.show_tutorial_list()
end, { desc = "Show available tutorials" })

vim.api.nvim_create_user_command("YodaHelp", function()
  M.show_help_list()
end, { desc = "Show help topics" })

vim.api.nvim_create_user_command("YodaContextualHelp", function()
  M.show_contextual_help()
end, { desc = "Show contextual help" })

vim.api.nvim_create_user_command("YodaStartTutorial", function()
  local tutorial_id = vim.fn.input("Enter tutorial ID: ")
  if tutorial_id and tutorial_id ~= "" then
    M.start_tutorial(tutorial_id)
  end
end, { desc = "Start a specific tutorial" })

-- Initialize the help system
M.init()

return M 