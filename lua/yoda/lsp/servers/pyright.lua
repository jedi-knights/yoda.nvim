return {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "strict", -- use "strct" for stricter type checking or "basic"
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly", -- or "workspace"
      },
    },
  },
}

