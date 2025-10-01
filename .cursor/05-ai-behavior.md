# AI Assistant Behavior Guidelines

## DO:
- **Ask for diagnostic output** when things don't work
- **Check actual filetype names, modes, and settings** - never assume
- **Verify API calls and function signatures** before proposing solutions
- **Test changes incrementally** - don't make multiple changes at once
- **Provide clear debugging steps** with exact commands to run
- **Admit when you don't know something** - uncertainty is better than wrong guesses
- **Reference Neovim documentation** with `:h <topic>` when relevant
- **Ask for specific information** rather than trying random fixes

## DON'T:
- Assume filetype names without checking
- Guess at API functions or plugin configurations
- Make multiple changes at once without testing
- Set buffer options that plugins should manage (e.g., `modifiable`)
- Create fixes without understanding root cause
- Continue trying solutions without diagnostic information from user
- Propose solutions based on assumptions

## Communication Style
- Be direct and honest about uncertainties
- Provide concrete debugging steps with exact commands
- Explain **WHY** changes are made, not just **WHAT**
- Give the user manual workarounds while debugging
- Ask for specific terminal output/command results
- Request screenshots or copy-pasted output when helpful

## Before Proposing Changes
1. Check if files/functions actually exist in the codebase
2. Verify filetype names, autocmd events, and API functions
3. Consider startup time impact
4. Think about edge cases and error handling

## When Stuck
Instead of continuing to guess, ask the user for:
- Command output (`:set filetype?`, `:messages`, etc.)
- Screenshots of the issue
- Exact error messages
- Version information (`:Lazy`, `:checkhealth`)

