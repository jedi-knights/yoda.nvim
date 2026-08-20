# Architecture

Living document for architectural principles and structural decisions. Tactical migration state lives in `TODO.md`; historical grill/design threads live in git.

## Positioning

**yoda.nvim is an AI-first Neovim distribution.**

The differentiator vs LazyVim is opinionation toward AI-augmented development. Core ships:

- `startup_mode.lua` — the `nvim claude` / `nvim c` boot mode
- `claudecode.nvim` integration
- Opinionated `<leader>ai*` keymaps
- AI-workspace layout defaults (snacks dashboard, etc.)

Language stacks (Rust, Python, Node, Go) are opt-in extras, not core.

## ICP

**Public Neovim distribution, LazyVim-parity install shape.** Not personal config, not "just Omar's dotfiles." All downstream decisions inherit from this — release automation, per-plugin pinning discipline, docs quality, semver contract, deprecation windows.

## Distribution shape

Plugin-first split, mirroring the LazyVim + LazyVim/starter model:

- **`jedi-knights/yoda.nvim`** — the plugin itself (this repo)
- **`jedi-knights/yoda-starter`** — the template repo users clone into `~/.config/nvim/`

The starter contains only a lazy.nvim bootstrap and a `plugins/yoda.lua` spec that pulls in yoda. Users' personal plugins and overrides live in the starter's `plugins/overrides.lua`.

Configuration is passed via `opts` on the plugin spec table, consumed by `require("yoda").setup(opts)`. `vim.g.yoda_*` globals are not part of the public config surface — they leak across plugins and cannot be validated.

## Directory layout

```
lua/yoda/
├── init.lua          -- Facade: setup(opts), public API
├── config.lua        -- Builder: defaults + vim.tbl_deep_extend + vim.validate
├── options.lua       -- distribution defaults (vim.opt.*)
├── keymaps.lua       -- aggregates lua/yoda/keymaps/*
├── autocmds.lua      -- non-plugin autocommands
├── commands.lua      -- runtime commands needing config
├── highlights.lua    -- highlight overrides
├── health.lua        -- :checkhealth yoda
│
├── plugins/          -- 17 core specs, one plugin per file
├── extras/lang/      -- opt-in language stacks (lua, rust, python, go, node)
│
├── core/             -- pure logic, NO vim.api imports (headless-testable)
└── ui/               -- vim.api wiring (autocmds, buffer options, notifications)

plugin/yoda.lua       -- bootstrap user commands so lazy-loading works
doc/yoda.txt          -- vimdoc: :help yoda
```

`core/` and `ui/` are a mandatory split: every domain module with mixed pure logic + Neovim API access is decomposed into a `core/` half (testable) and a `ui/` half (wiring). This unlocks headless unit tests and enforces the layering rule from `~/.claude/rules/nvim-lua.md`.

## Extras loading

Language stacks are opted in the LazyVim way — the starter adds explicit `import` entries:

```lua
return {
  { "jedi-knights/yoda.nvim", import = "yoda.plugins", opts = {...}, config = function(_, opts) require("yoda").setup(opts) end },
  { import = "yoda.extras.lang.rust" },
  { import = "yoda.extras.lang.python" },
}
```

`opts.extras` is **not** a load switch — lazy.nvim resolves its spec graph before any `config` callback fires, so an extras field on `opts` can't drive imports. Explicit `import` entries are the mechanism.

## Bootstrap flow

`plugin/yoda.lua` registers only bootstrap commands (`:Yoda`, `:YodaExtras`, `:YodaHealth`) that lazy-trigger the plugin.

`setup(opts)` runs from the starter's lazy spec `config` callback and executes deterministically:

1. `vim.validate(opts)` — fail loud
2. Merge into `M.config` via `require("yoda.config").resolve(opts)`
3. Apply options / highlights / autocmds / keymaps (each gated by `config.defaults.*` for starter escape hatches)
4. Register runtime commands
5. Wire `ui/large_file`, `ui/environment`, `ui/startup_mode`, `ui/screencast`

Every autocmd group uses `nvim_create_augroup(name, { clear = true })` so re-invocation is idempotent.

**Fail loud, not silent.** The scheduled-block-with-`pcall` pattern from personal-config days is gone. In a public distribution, silent degradation hides regressions from contributors — a missing module surfaces as a Lua error at the plugin boundary.

## `opts` schema (public config surface)

```lua
require("yoda").setup({
  ui           = { verbose_startup, show_loading_messages, show_environment_notification, show_startup_report },
  profiling    = { enable, verbose },
  adapters     = { notification, picker },       -- backend selection
  large_file   = { enable, size_threshold, show_notification, disable = {...} },
  yaml         = { known_environments, env_indent, region_indent },
  testing      = {...},
  startup_mode = { enable, triggers },
  defaults     = { options, keymaps, autocmds }, -- starter escape hatches
})
```

Every key maps 1:1 to what `vim.g.yoda_*` covered in the pre-v1 config. Defaults live in `lua/yoda/config.lua`; users overlay via `vim.tbl_deep_extend("force", defaults, opts)`.

## Testing

- **Runner**: [`neospec`](https://github.com/jedi-knights/neospec) — a single binary that fetches its own pinned Neovim
- **Layout**: `tests/yoda/**/*_spec.lua` mirrors `lua/yoda/**/*.lua`
- **Bootstrap**: `tests/minimal_init.lua` prepends the repo to runtimepath and stubs the `yoda-*` siblings; neospec supplies the harness
- **`core/` modules** are exercised without loading Neovim's plugin runtime, so the fast test loop stays fast

Coverage is emitted by `make test-coverage` (lcov), and covers lines *and*
functions. It requires neospec >= v0.6.0, which counts executable-but-unexecuted
lines, includes source files no test loads (via `--coverage-source`), and emits
lcov `FN`/`FNDA` records.

The number is a real signal now — it was ~100% by construction before v0.6.0,
because the denominator was the set of lines that had executed. Current state is
roughly 38% line and 38% function coverage; the largest gaps are the keymap
modules, whose bodies register mappings while the callbacks never run under
test.

## LSP

Currently `mason.nvim` + `mason-lspconfig` drive server setup. Migration to native `vim.lsp.config` + `lsp/<server>.lua` per Neovim 0.11+ is deferred to v1.1 — it's a substantial rewrite orthogonal to the v1.0.0 restructure.

## Release model

- Semantic versioning via `jedi-knights/go-semantic-release@v0.11.0`
- Conventional Commits — `feat!:` triggers major, `feat:` minor, `fix:` patch
- Release workflow gated on CI success via `workflow_run`
- `v0.1.0` was tagged as the baseline before the v1.0.0 restructure

## Sibling plugins

The six `yoda-*.nvim` companion plugins (`yoda.nvim-adapters`, `yoda-core.nvim`, `yoda-logging.nvim`, `yoda-terminal.nvim`, `yoda-window.nvim`, `yoda-diagnostics.nvim`) are declared as `dependencies` on the core yoda spec. Importing `yoda.plugins` cascades them, so yoda works standalone from a fresh `:Lazy sync` without the starter having to know about them.

## Stability

Yoda is a distribution — other people depend on it. Priority order:

**Stability > Functionality > Performance > Latest Features**

See `.claude/rules/stability-first.md` for the decision framework applied to every plugin change.

## References

- `TODO.md` — current tactical migration state
- `CLAUDE.md` — AI assistant context and validation commands
- `.claude/rules/stability-first.md` — plugin update policy
- `~/.claude/rules/nvim-lua.md` — plugin architecture rule (init/config/commands/keymaps/autocmds/core/ layout)
- `~/.claude/rules/nvim-lazy.md` — one-plugin-per-file spec rule
