# Architecture Decision Record: Adopt Conventional Commits

## Status
Accepted

## Context

As part of building a well-documented, beginner-friendly Neovim distribution, it's important to maintain clear, consistent, and meaningful commit history. A structured commit format helps:

- Make it easier to read and understand project history.
- Enable better automation for changelogs, releases, and versioning.
- Lower the barrier for contributors to know what type of changes are expected.

The [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification provides a widely adopted standard that is simple yet powerful for this purpose.

## Decision

I have decided to adopt **Conventional Commits** for all commit messages in the `yoda` repository.

Examples:

```
feat: add treesitter integration for better syntax highlighting
fix: correct nvim-cmp setup error when no LSP is attached
docs: add installation guide to README
refactor: simplify LSP config setup
chore: update lazy.nvim to latest version
test: add tests for plugin manager module
```

Commit types that will be supported:

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (e.g., formatting)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools

Optional:
- `build`, `ci`, `revert`, and `BREAKING CHANGE` annotations if the project complexity grows

## Consequences

- **Positive**:
  - Creates a predictable, readable commit history.
  - Facilitates automatic changelog generation and release notes.
  - Makes collaboration easier, even for newcomers.

- **Negative**:
  - Slight additional burden for contributors to learn and follow the format.

## Next Steps

- Document Conventional Commits usage in the `CONTRIBUTING.md` guide.
- Optionally set up a commit message linter (e.g., `commitlint`) later.

---

_This ADR will be revisited once community contributions begin to assess if stricter tooling is needed._


