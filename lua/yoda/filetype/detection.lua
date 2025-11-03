-- lua/yoda/filetype/detection.lua
-- Filetype detection patterns and configuration

local M = {}

-- ============================================================================
-- Detection Patterns
-- ============================================================================

M.PATTERNS = {
  jenkinsfile = {
    "Jenkinsfile",
    "*.Jenkinsfile",
    "jenkinsfile",
    "*.jenkinsfile",
    "*.jenkins",
    "*jenkins*",
  },
}

-- ============================================================================
-- Filetype Handlers
-- ============================================================================

--- Configure Jenkinsfile for Groovy syntax with Jenkins keywords
function M.configure_jenkinsfile()
  vim.bo.filetype = "groovy"
  vim.bo.syntax = "groovy"

  -- Add Jenkins-specific keywords for better syntax highlighting
  vim.cmd([[
    syntax keyword groovyKeyword pipeline agent stages stage steps script sh bat powershell
    syntax keyword groovyKeyword when environment parameters triggers tools options
    syntax keyword groovyKeyword post always success failure unstable changed cleanup
    syntax keyword groovyKeyword parallel matrix node checkout scm git svn
    syntax keyword groovyKeyword build publishHTML archiveArtifacts publishTestResults
    syntax keyword groovyKeyword junit testReport emailext slackSend
    syntax match groovyFunction /\w\+\s*(/
  ]])
end

-- ============================================================================
-- Setup Functions
-- ============================================================================

--- Setup Jenkinsfile detection autocmd
--- @param autocmd function vim.api.nvim_create_autocmd function
--- @param augroup function vim.api.nvim_create_augroup function
function M.setup_jenkinsfile_detection(autocmd, augroup)
  autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup("YodaJenkinsfile", { clear = true }),
    desc = "Detect Jenkinsfile and configure for Jenkins Pipeline syntax",
    pattern = M.PATTERNS.jenkinsfile,
    callback = M.configure_jenkinsfile,
  })
end

--- Setup all filetype detection autocmds
--- @param autocmd function vim.api.nvim_create_autocmd function
--- @param augroup function vim.api.nvim_create_augroup function
function M.setup_all(autocmd, augroup)
  M.setup_jenkinsfile_detection(autocmd, augroup)
end

return M
