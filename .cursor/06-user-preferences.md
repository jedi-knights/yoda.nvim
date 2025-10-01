# User Preferences

## Coding Conventions
- Use conventional commits with Angular commit message convention
- Prefer using snacks.nvim test harness over plenary.test_harness
- Replace directories with multiple plugin references with single files using tables
- Use Vim mappings `<leader>ff` for file finding and `<leader>fg` for fuzzy finding

## AI Provider Configuration
- Avante is configured to use Mercury (internal AI solution)
- User wants ability to switch AI providers based on location (home vs work)

## Documentation
- Maintain Architecture Decision Records (ADRs) in `docs/adr/`
- Keep documentation up to date with changes
- Document "why" not just "what"

## Known Issues to Track
- Snacks Explorer opening in wrong mode (investigating filetype/autocmd interaction)
- Need to verify exact filetype name for Snacks Explorer

