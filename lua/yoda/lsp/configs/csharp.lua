-- lua/yoda/lsp/configs/csharp.lua
-- C# language server configuration

local M = {}

--- Create omnisharp configuration
--- @param builder LSPConfigBuilder
--- @return table
function M.create_config(builder)
  return builder
    :with_filetypes({ "cs", "csx", "cake" })
    :with_settings({
      OmniSharp = {
        enableRoslynAnalyzers = true,
        enableEditorConfigSupport = true,
        enableImportCompletion = true,
        enableAsyncCompletion = true,
        enableSnippets = true,
        organizeImportsOnFormat = true,
        enableMsBuildLoadProjectsOnDemand = false,
        useModernNet = true,
        projectLoadTimeout = 60,
        maxProjectResults = 250,
        maxProjectFileResults = 50,
        enableSemanticHighlighting = true,
        enableHighlightRelated = true,
        enableHighlightTypedSymbols = true,
        enableInlayHints = true,
        enableInlayHintsForParameters = true,
        enableInlayHintsForLiteralParameters = true,
        enableInlayHintsForIndexerParameters = true,
        enableInlayHintsForObjectCreationParameters = true,
        enableInlayHintsForOtherParameters = true,
        suppressInlayHintsForParametersThatDifferOnlyBySuffix = false,
        suppressInlayHintsForParametersThatMatchMethodIntent = false,
        suppressInlayHintsForParametersThatMatchArgumentName = false,
        enableInlayHintsForTypes = true,
        enableInlayHintsForImplicitVariableTypes = true,
        enableInlayHintsForLambdaParameterTypes = true,
        enableInlayHintsForImplicitObjectCreation = true,
      },
    })
    :build()
end

return M
