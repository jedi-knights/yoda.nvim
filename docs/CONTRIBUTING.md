# Contributing to Yoda

First, thank you for considering contributing! 🎉  
This project is designed to grow alongside its users — so whether you're learning, experimenting, or an experienced developer, your help is welcome.

---

## How to Contribute

- 🛠 **Improve the Configuration:**  
  - Add, configure, or improve plugins.
  - Enhance startup performance.
  - Make the modularity even better.

- 🮩 **Documentation Contributions:**  
  - Improve the README, ADRs, or any doc files.
  - Expand tutorials, examples, or setup guides.
  - Clarify anything that could confuse a new user.

- 🐛 **Bug Reports and Fixes:**  
  - If something doesn’t work, open an issue or pull request.
  - Fix broken keymaps, plugin configs, or setup errors.

- 💡 **Suggest New Features:**  
  - Propose beginner-friendly enhancements.
  - Suggest additional supported plugins or LSP servers.

---

## Contribution Guidelines

- **Keep it Beginner-Friendly:**  
  Aim for clean, modular, and easy-to-understand code and documentation.

- **Follow Conventional Commits:**  
  Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format in your commit messages:  
  Example:
  - `feat(lsp): add jsonls server support`
  - `fix(keymaps): correct typo in visual mode mapping`
  - `docs(readme): add installation instructions`

- **Modularity First:**  
  - Add new settings under appropriate directories (e.g., `core/`, `plugins/spec/`, `lsp/servers/`).
  - Avoid putting everything into a single file.

- **Testing:**  
  - Try to test your changes locally by reloading Neovim and checking for errors.
  - Use `:Lazy sync` after adding or updating plugins.

- **Polite Collaboration:**  
  - Be kind and respectful in comments, discussions, and PRs.
  - Yoda is a welcoming place for all learners.

---

## Development Setup

To work on Yoda:

1. Clone your fork locally:
   ```bash
   git clone https://github.com/<your-username>/yoda
   cd yoda
   ```

2. Open Neovim:
   ```bash
   nvim
   ```

3. Run `:Lazy sync` to install all plugins.

4. Start editing files inside `lua/yoda/`.

---

## Opening a Pull Request

- Create a feature branch from `main`.
- Make sure your changes are clean and documented.
- Submit a pull request with a clear description of what you changed and why.

---

# 🧠 A Note on Learning

It's okay if you're learning along the way.  
The project itself is built to **help people level up** while working with Neovim.  
Mistakes are part of learning — **don't be afraid to contribute!** 🚀

---

> "Train yourself to let go of everything you fear to lose." — Yoda


