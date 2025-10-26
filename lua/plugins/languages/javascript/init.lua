-- lua/plugins/languages/javascript/init.lua
-- JavaScript/TypeScript language support meta-loader

return {
  { import = "plugins.languages.javascript.dap_vscode_js" },
  { import = "plugins.languages.javascript.neotest_jest" },
  { import = "plugins.languages.javascript.neotest_vitest" },
  { import = "plugins.languages.javascript.package_info" },
}
