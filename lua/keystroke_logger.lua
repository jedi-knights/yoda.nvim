local M = {}

local ns = vim.api.nvim_create_namespace("keystroke_logger")
local buf, win
local keystrokes = ""
local timer

-- Create the floating window
local function create_window()
    buf = vim.api.nvim_create_buf(false, true)
    local width = 30
    local height = 1
    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = vim.o.lines - 3,
        col = vim.o.columns - width - 2,
        style = 'minimal',
        border = 'single',
    }
    win = vim.api.nvim_open_win(buf, false, opts)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

-- Update the floating window with current keystrokes
local function update_window()
    if not win or not vim.api.nvim_win_is_valid(win) then
        create_window()
    end
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { keystrokes })
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

-- Reset the keystroke display after a delay
local function reset_timer()
    if timer then
        timer:stop()
        timer:close()
    end
    timer = vim.loop.new_timer()
    timer:start(1000, 0, vim.schedule_wrap(function()
        keystrokes = ""
        update_window()
    end))
end

-- Start the keystroke logger
function M.start()
    vim.on_key(function(key)
        -- skip mouse input
        if key:match("<") then return end
        keystrokes = keystrokes .. key
        update_window()
        reset_timer()
    end, ns)
    print("✅ Keystroke logger started")
end

-- Stop the keystroke logger
function M.stop()
    vim.on_key(nil, ns)
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
    print("🛑 Keystroke logger stopped")
end

return M
