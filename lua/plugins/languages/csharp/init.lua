-- lua/plugins/languages/csharp/init.lua
-- C# language support meta-loader

return {
  { import = "plugins.languages.csharp.roslyn" },
  { import = "plugins.languages.csharp.neotest_dotnet" },
}
