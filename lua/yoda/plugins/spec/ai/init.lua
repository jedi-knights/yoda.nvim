-- lua/yoda/plugins/spec/ai/init.lua

local plugins = {
    require("yoda.plugins.spec.ai.copilot"),
    require("yoda.plugins.spec.ai.mcphub"),
}

if vim.env.YODA_ENV == "work" then
    table.insert(plugins, require("yoda.plugins.spec.ai.mercury"))
end

return plugins
