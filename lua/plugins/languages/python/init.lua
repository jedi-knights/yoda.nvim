-- lua/plugins/languages/python/init.lua
-- Python language support meta-loader

return {
  { import = "plugins.languages.python.neotest_python" },
  { import = "plugins.languages.python.dap_python" },
  { import = "plugins.languages.python.venv_selector" },
}
