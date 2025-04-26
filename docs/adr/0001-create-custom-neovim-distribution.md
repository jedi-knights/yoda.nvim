# Architecture Decision Record: Create Custom Neovim Distribution

## Status
Accepted

## Context

As a novice in the Neovim ecosystem, I recognize the challenges and steep learning curve that new users often face when transitioning from traditional editors or IDEs. My goals are to:

- Learn Neovim deeply by building and documenting a full configuration from scratch.
- Create a well-documented, beginner-friendly Neovim distribution.
- Offer an accessible starting point for others who are new to Neovim.
- Promote a learning-first philosophy where documentation, transparency, and simplicity are prioritized.

This distribution will serve both as a personal learning journey and a resource to help others become productive in Neovim faster.

## Decision

I have decided to create a **custom Neovim distribution** named **Yoda** under the GitHub organization [jedi-knights](https://github.com/jedi-knights).

Key initial decisions:

- **Repository**: `jedi-knights/yoda`
- **License**: MIT License (to encourage open collaboration and widespread adoption)
- **Tagline**: "A Jedi's first steps into the Neovim universe."
- **Goals**:
  - Provide a modular, extensible, and beginner-friendly Neovim setup.
  - Prioritize simplicity, clarity, and ease of understanding over maximal feature set.
  - Document every decision, configuration file, and plugin choice with detailed explanations.
  - Focus on common workflows for general development (with Python, Go, Web languages, etc.).
- **Technical Approach**:
  - Lua-based configuration.
  - Plugin management via `lazy.nvim`.
  - Simple, well-organized module structure (e.g., UI, LSP, Completion, Git, Testing).
  - Focus on building a strong foundation first before adding more advanced customizations.

## Consequences

- **Positive**:
  - Greatly aids my personal growth and understanding of Neovim internals.
  - Provides a documented learning path for others.
  - Creates a maintainable and transparent distribution that new users can trust.
  - Establishes a foundation for potentially more advanced versions later.

- **Negative**:
  - Limited initial features compared to mature Neovim distributions.
  - Documentation effort will be significant and must be actively maintained.
  - Project scope must be carefully managed to avoid overwhelming complexity.

- **Next Steps**:
  - Bootstrap the basic repository structure.
  - Set up foundational modules: UI, basic LSP support, syntax highlighting, simple Git integration.
  - Focus first on stability, simplicity, and documentation.
  - Publish an initial "starter" release aimed at total beginners.

---

_This ADR will be revisited after the first release milestone to evaluate progress, usability, and potential next steps._


