# yoda.nvim — v1.0.0 restructure handoff

**Status:** Step 1 done. Steps 2 and 3 remain.
**Written:** 2026-08-18 after `/architect grill` session that decided the v1.0.0 direction.
**For future Claude:** read this file top-to-bottom before touching any code. All context needed to resume is here or linked from here. This is a **persistent handoff document**, not the ephemeral session `TODO.md` referenced in the root `CLAUDE.md` — that convention was for in-session scratch; this file overrides it for the duration of the v1.0.0 restructure.

---

## Positioning (locked)

**yoda.nvim is an AI-first Neovim distribution.**

Differentiator vs LazyVim: opinionated toward AI-augmented development. Core ships `startup_mode.lua` (the `nvim claude` / `nvim c` boot mode), `claudecode.nvim` integration, opinionated `<leader>ai*` keymaps, and AI-workspace layout defaults. Language stacks (Rust, Python, Node, Go) are opt-in extras. If a future decision would weaken this positioning, stop and re-grill Q6.

## ICP (locked)

**Public Neovim distribution, LazyVim-parity install shape.** Not personal config, not "just Omar's dotfiles." All downstream decisions (release automation, per-plugin pinning discipline, docs quality, semver contract, deprecation windows) inherit from this. If a future decision would only make sense for a personal config, stop and re-grill Q1.

---

## Grilled decisions (7 confirmed, do NOT relitigate without new evidence)

| # | Decision | Answer |
|---|---|---|
| Q1 | ICP | Public Neovim distribution, LazyVim-parity install shape |
| Q2 | Release model | `jedi-knights/go-semantic-release@v0.11.0`, `workflow_run` gated on CI success, push-to-main + `workflow_dispatch` triggers |
| Q3-sub | Config vessel | `opts` on spec table + `require("yoda").setup(opts)` (NOT `vim.g.yoda_*` globals) |
| Q3 | Extras model | `lua/yoda/extras/<domain>/*.lua`, opted-in via `opts.extras = { "lang.rust", ... }` |
| Q4 | Distribution shape | Plugin-first split: `jedi-knights/yoda.nvim` (the plugin, this repo) + `jedi-knights/yoda-starter` (new template repo) |
| Q5 | Migration | 3 steps on existing repo, no history rewrite: (1) tag v0.1.0 first ✅, (2) restructure to plugin shape as `feat!:` → v1.0.0, (3) publish yoda-starter + dogfood |
| Q6 | Positioning | AI-first Neovim distribution |
| Q7 | Core/extras split | 17 core specs + 5 chunky extras (see decomposition table below) |

## Grilled and REJECTED (do NOT propose these again without new evidence)

- Personal-config framing (Q1) — public distribution decided
- Rolling-only release / no artifact to pin (Q2)
- `vim.g.yoda_*` config globals as primary config vessel (Q3-sub) — replaced by `opts`
- Flat 53-plugin always-installed surface (Q3) — replaced by extras
- Config-repo install (`git clone → ~/.config/nvim`) as the official path (Q4)
- Hybrid install (both config-repo AND plugin paths) — LazyVim v9→v10 lesson (Q4)
- History rewrite / force-push migration (Q5)
- v1.0.0 with a compat window supporting the old install path (Q5)
- "LazyVim + BDD/testing focus" positioning (Q6)
- "LazyVim + Rust-heavy defaults" positioning (Q6)
- "No differentiator, just personal preferences packaged" positioning (Q6) — would reopen Q1
- LazyVim-style fine-grained ~30 extras (Q7) — chunky 5-domain preferred; can subdivide later
- Separate `extras/dap/core` and `extras/test/core` (Q7) — kept in core for out-of-box UX

---

## Step 1 — DONE (Session 1, 2026-08-18)

- ✅ `.github/workflows/release.yml` added (`jedi-knights/go-semantic-release@v0.11.0`, `workflow_run` gated on CI success)
- ✅ Landed via PR #63 (squash-merged as commit `3c5bc76`)
- ✅ `v0.1.0` annotated tag pushed to origin, pointing at `3c5bc76`; tag message contains grill summary — `git show v0.1.0` to read
- ✅ Release workflow verified to run without cutting a spurious release

**⚠️ Caveat to validate on Step 2:** On the first workflow run (before v0.1.0 tag was pushed), go-semantic-release logged `analyzed commits total=933 parsed=933 → No releasable changes found` despite plenty of `feat:` / `fix:` commits in history. Likely explanation: needs an existing baseline tag before it will cut. Now that v0.1.0 exists, the Step 2 `feat!:` commit **should** trigger v1.0.0. If it doesn't after merging Step 2's PR, add a `.releaserc.json` (or equivalent go-semantic-release config file) tuning `initial-version` or branch rules before continuing. Reference other repos' configs for the pattern.

---

## Step 2 — TODO (biggest chunk; multi-session)

Restructure the repo into a plugin-shaped distribution. Land as a **single conventional-commit**: `feat!: repackage as installable plugin` — the `!` triggers a major bump; go-semantic-release should cut `v1.0.0`.

**Recommend starting with `/architect design nvim` in a fresh session** to lay out the concrete file-level plan before touching code. Then execute in stages, ideally each in its own PR so review is tractable. Or one big PR if you prefer — this is a breaking change either way.

### Step 2A: New plugin entry points

- [ ] Create `lua/yoda/init.lua` — public API returning `setup(opts)`; delegates to `config` / `plugins` / etc. per `nvim-lua.md` plugin architecture rule
- [ ] Create `lua/yoda/config.lua` — defaults + `vim.tbl_deep_extend("force", defaults, opts)` merge; also validates with `vim.validate` per rule
- [ ] Create `plugin/yoda.lua` — bootstrap user commands (`:Yoda`, `:YodaExtras`, etc.) so lazy-loading works
- [ ] Create `doc/yoda.txt` — vimdoc help file, `:help yoda` becomes discoverable
- [ ] Delete top-level `init.lua`, `lua/lazy-bootstrap.lua`, `lua/lazy-plugins.lua` — these move to yoda-starter's job
- [ ] `lua/options.lua` and `lua/autocmds.lua` — decision needed: (a) stay as yoda-owned modules that `setup()` calls, or (b) move to yoda-starter. Recommend (a) — they're distribution-level defaults, not user config

### Step 2B: Move + split plugin specs to `lua/yoda/plugins/`

Per `nvim-lazy.md` rule: **one plugin per file for logical groups.** Current 22 files → 17 core specs (splitting bundled ones):

**Core plugins (`lua/yoda/plugins/`) — 17 specs:**

| File | Plugin(s) | Notes |
|---|---|---|
| `ai.lua` | `claudecode.nvim` | Differentiator; keep in core |
| `blink-cmp.lua` | `blink.cmp` | Move from `lua/plugins/` |
| `colorscheme.lua` | `tokyonight.nvim` | Rename from `tokyonight.lua`; `lazy = false, priority = 1000` |
| `conform.lua` | `conform.nvim` | Move as-is |
| `dap-core.lua` | `nvim-dap` + `nvim-dap-ui` + `nvim-dap-virtual-text` | **Split from `lua/plugins/nvim-dap.lua`** — adapters go to extras |
| `difftool.lua` | `nvim.difftool` (virtual) | Move as-is |
| `git.lua` | `gitsigns.nvim` + `diffview.nvim` + `neogit` | Keep bundled — deliberate git-first stance |
| `lualine.lua` | `lualine.nvim` | Move as-is |
| `mason.lua` | `mason.nvim` + `mason-lspconfig` | Move as-is |
| `mini.lua` | `mini.nvim` collection | Move as-is |
| `neotest-core.lua` | `neotest` + `neotest-plenary` + `nvim-coverage` | **Split from `lua/plugins/testing.lua`** — language adapters go to extras |
| `nvim-lint.lua` | `nvim-lint` | Move as-is |
| `plenary.lua` | `plenary.nvim` | Move as-is |
| `snacks.lua` | `snacks.nvim` | Move as-is; heavily integrated with AI boot mode |
| `treesitter.lua` | `nvim-treesitter` (+ context, textobjects if present) | Rename from `nvim-treesitter.lua` |
| `undotree.lua` | `undotree` | Move as-is |
| `which-key.lua` | `which-key.nvim` | Move as-is |

**Extras (`lua/yoda/extras/lang/`) — 5 chunky domains:**

| File | Plugins pulled in | Opts-in via |
|---|---|---|
| `lua.lua` | `lazydev.nvim` | `opts.extras = { "lang.lua" }` |
| `rust.lua` | `rustaceanvim` + `crates.nvim` + `nvim-dap` Rust adapter config | `opts.extras = { "lang.rust" }` |
| `python.lua` | `nvim-dap-python` + `neotest-python` + `pytest-atlas.nvim` | `opts.extras = { "lang.python" }` |
| `go.lua` | `nvim-dap-go` + `neotest-golang` | `opts.extras = { "lang.go" }` |
| `node.lua` | `package-info.nvim` + JS/TS DAP adapter config + `neotest-jest` + `neotest-vitest` | `opts.extras = { "lang.node" }` |

**Files to delete from `lua/plugins/`:** all of them (moved or split).

**Files that get consolidated:** `lazydev.lua`, `rust.lua`, `package-info.lua` → all become extras.

### Step 2C: Config vessel migration (`vim.g.yoda_*` → `opts`)

Grep for every `vim.g.yoda_*` usage and migrate to `opts.<name>` via the `require("yoda").setup(opts)` path.

Known globals (grep to confirm — this list may be incomplete):
- [ ] `vim.g.yoda_large_file` → `opts.large_file` (see `init.lua:93` and `lua/yoda/large_file.lua`)
- [ ] `vim.g.yoda_config` → `opts` root or a sub-key (see `lua/yoda/environment.lua:15`)
- [ ] Anything else `grep -rn "vim.g.yoda_" lua/ init.lua` turns up

Load-order note: with `opts` there's no more scheduled block dance. The `opts` merge happens at plugin-load time (deterministic), so the scheduled-block-with-pcall pattern in the current `init.lua` becomes unnecessary.

### Step 2D: Parked tactical decisions (from grill Unresolved section)

- [ ] **Strip defensive `pcall`-around-every-module scaffolding** from the current `init.lua`. Public distributions **fail loud** (assert/error surfacing at the boundary), not silently-degrade. Current pattern is a personal-config habit that hides regressions from contributors. Convert to plain `require()` + let errors propagate; the plugin lifecycle boundary handles them.
- [ ] **Swap `neospec` (custom Go binary test runner) → `plenary.nvim`** for the test suite. Rationale: `plenary.nvim` requires zero out-of-band install step — lazy.nvim fetches it like any other plugin dependency — whereas `neospec` always needs a separate install step before `make test` works. Update `Makefile` (currently `go install github.com/jedi-knights/neospec/cmd/neospec@latest` — could switch to `brew install jedi-knights/tap/neospec` now that the formula is published, but that's still an extra manual step `plenary.nvim` doesn't need), `.github/workflows/ci.yml` (currently uses `jedi-knights/neospec@v0.1.4`), `tests/minimal_init_fast.lua`, `neospec.toml` (delete).

  **Update, 2026-08-19:** the `brew install jedi-knights/tap/neospec` path documented in neospec's README was previously dead — the formula was never published (`jedi-knights/homebrew-tap`'s `Formula/` had no `neospec.rb`, and GoReleaser had no `brews:` block to generate one). Fixed via [neospec#26](https://github.com/jedi-knights/neospec/pull/26) (adds the `brews:` block + `HOMEBREW_TAP_GITHUB_TOKEN` so future releases auto-publish) and [homebrew-tap#4](https://github.com/jedi-knights/homebrew-tap/pull/4) (backfilled `Formula/neospec.rb` for the existing v0.4.0 release, checksums verified against the real release asset). Both merged 2026-08-19 — `brew install jedi-knights/tap/neospec` now actually works. This does not change the recommendation above: the zero-out-of-band-install argument for `plenary.nvim` still holds regardless of which install method `neospec` offers.

### Step 2E: `lua/custom/plugins/` — delete

- [ ] Delete `lua/custom/plugins/` — this becomes yoda-starter's `lua/plugins/overrides.lua`. Not needed in yoda-the-plugin.

### Step 2F: Docs

- [ ] Rewrite `README.md` for plugin+starter install model (install snippet shows yoda-starter clone, not the old direct-config clone)
- [ ] Add "The yoda way" section covering AI-first ergonomics: `nvim claude`/`nvim c` boot mode, claudecode integration, snacks-dashboard AI keymaps, `<leader>ai*` conventions
- [ ] Migration guide for v0.1.0 users: "if you're on the old clone-into-nvim-config path, here's how to switch to yoda-starter"
- [ ] Update `CONTRIBUTING.md` for the new dev loop (no more `make install` for neospec; use plenary via `:PlenaryBustedDirectory` or Makefile target)
- [ ] Update `CLAUDE.md` if needed — the ICP + positioning are now decided, add them to the top of the file

### Step 2G: CI updates

- [ ] Update `.github/workflows/ci.yml`:
  - Test job: swap `jedi-knights/neospec@v0.1.4` step → run plenary via `nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"` or similar
  - Consider adding a smoke-test job: install yoda-the-plugin in a fresh Neovim + yoda-starter layout, boot, verify `:Yoda` commands work, verify no errors on VimEnter
- [ ] Verify release workflow still works after the restructure (the ci.yml changes may need corresponding release.yml tweaks if the CI job names change)

### Step 2H: Verify release automation (THE big validation moment)

- [ ] Merge PR for `feat!: repackage as installable plugin`
- [ ] Watch the Release workflow run — should compute v1.0.0 from the `feat!:` marker (breaking change → major bump from v0.1.0 → v1.0.0)
- [ ] If v1.0.0 is NOT cut, check the go-semantic-release logs. Likely fix: add `.releaserc.json` at repo root with explicit `branches: ["main"]` and `initialVersion` or `tagFormat` config. Consult jedi-knights/go-platform or gherkin-fmt for working config examples.

---

## Step 3 — TODO (after Step 2 lands)

Publish the starter template + dogfood by migrating your own `~/.config/nvim/` to the new shape.

### Step 3A: Create `jedi-knights/yoda-starter` repo

Layout (per Q4 decision — mirror LazyVim's `LazyVim/starter`):

```
yoda-starter/                     (cloned into ~/.config/nvim/)
├── init.lua                      -- 3 lines: bootstrap lazy + import yoda
├── lua/
│   ├── config/
│   │   └── lazy.lua              -- lazy.nvim bootstrap
│   └── plugins/
│       ├── yoda.lua              -- { "jedi-knights/yoda.nvim", version = "*", import = "yoda.plugins", opts = {...} }
│       └── overrides.lua         -- user's personal plugins and yoda overrides (empty by default)
├── stylua.toml
├── LICENSE                       -- MIT
└── README.md                     -- "Clone this into ~/.config/nvim/"
```

- [ ] Create the repo on GitHub
- [ ] Mark it as a **template repository** in GitHub settings (so users can click "Use this template" on GitHub)
- [ ] Add README with install instructions matching the LazyVim starter's shape
- [ ] Tag the starter repo separately — usually a starter follows the plugin's major version (starter v1.x tracks yoda v1.x)

### Step 3B: Dogfood — migrate your own dotfiles

- [ ] BEFORE tagging Step 2's v1.0.0 (per Q5 recommendation): clone yoda-starter to a fresh location (e.g., `~/src/yoda-dotfiles/`), point `$NVIM_APPNAME` at it, use it as your daily driver for at least a few days
- [ ] Fix anything broken (missing extras, wrong opts merge, dashboard glitches, etc.)
- [ ] Only then merge the Step 2 PR that tags v1.0.0
- [ ] After v1.0.0 is out: migrate your real `~/.config/nvim/` to the starter shape. Old repo can be archived or deleted from your machine (still exists on GitHub at v0.1.0 for anyone else who wants it)

---

## References for future Claude session

- `git show v0.1.0` — annotated tag with the grill decision summary
- `.claude/rules/stability-first.md` — project rule, applies to plugin picks
- `CLAUDE.md` — project instructions (may need updating in Step 2F)
- `~/.claude/skills/architect/` — grill/design/patterns skills used to reach these decisions
- **Reference release workflows** for `.releaserc.json` tuning if needed:
  - `~/src/github.com/jedi-knights/go-platform/.github/workflows/release.yml` (simplest)
  - `~/src/github.com/jedi-knights/gherkin-fmt/.github/workflows/release.yml` (uses npm-based semantic-release; different tool, but comparison of config patterns)
  - `~/src/github.com/jedi-knights/jk-mcp-ecnl/.github/workflows/release.yml` (with version-file sync + deploy — more complex than yoda needs)
- **Reference plugin distribution structure**: https://github.com/LazyVim/LazyVim (plugin repo) + https://github.com/LazyVim/starter (starter repo)
- **Existing bundled specs that must be split**:
  - `lua/plugins/nvim-dap.lua` (352 lines) — split scaffold (core) from language adapters (extras/lang/*)
  - `lua/plugins/testing.lua` (289 lines) — split neotest core (core) from language adapters (extras/lang/*)
  - `lua/plugins/git.lua` (249 lines) — keep bundled (all core, deliberate git-first stance)

## When you finish everything on this list

Delete this file. If v1.0.0 is out, yoda-starter is published, and you're daily-driving the starter shape, the migration is done.
