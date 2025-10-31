-- Test Lua file for syntax highlighting benchmark
local M = {}

function M.test_function()
    for i = 1, 100 do
        local result = math.random() * i
        if result > 50 then
            print("Result: " .. result)
        end
    end
end

return M
