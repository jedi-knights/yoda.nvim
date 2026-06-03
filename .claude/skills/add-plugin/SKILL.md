---
description: Add a new plugin to yoda.nvim through the conservative-update checklist — stability gate, spec file in lua/plugins/, lazy-loading triggers, version pinning, lazy-lock.json discipline, and validation. Use whenever the user asks to add, install, include, or wire up a new Neovim plugin.
argument-hint: "<author/plugin-name> [purpose]"
---

# Add Plugin

Use this skill whenever the user asks to add a new Neovim plugin to yoda.nvim. It enforces the discipline from `CLAUDE.md` and `.claude/rules/stability-first.md`, and produces a lazy.nvim spec that matches the surrounding code.

## Step 1 — Stability gate

Apply `.claude/rules/stability-first.md`. Produce the **Stability check** block first. Wait for user confirmation before touching any file. If the user redirects (different plugin, extend existing, decline) — follow that, do not proceed.

## Step 2 — Pick the lazy-loading trigger

Choose the most specific trigger that still loads the plugin when needed:

| Trigger | Use when |
|---|---|
| `cmd` | Plugin only runs when its `:Command` is invoked |
| `ft` | Plugin only needed for specific filetypes |
| `keys` | Plugin only needed when a keymap fires |
| `event` | Plugin needed at a lifecycle event |

Default to `event = "VeryLazy"` only when none fit. Reserve `lazy = false` for colorschemes and core UI (`tokyonight`, `lualine` already cover those).

Avoid `InsertEnter` for completion plugins — it causes first-insert lag.

## Step 3 — Pin the version

- Prefer `tag = "vX.Y.Z"` for plugins with semver releases.
- If no tags exist, omit `branch` (track default) and rely on `lazy-lock.json` to pin the commit.
- Never use `version = "*"` or `branch = "main"` unless the plugin has no other option.

## Step 4 — Write the spec file

Create `lua/plugins/<short-name>.lua` matching the style of neighbors:

```lua
-- lua/plugins/<short-name>.lua

return {
  "<author>/<plugin-name>",
  tag = "vX.Y.Z",                  -- or omit if untagged
  <trigger> = <trigger-value>,     -- cmd / ft / keys / event
  dependencies = { ... },          -- only direct deps, never transitive
  opts = {
    -- plain data — lazy.nvim calls require("<plugin>").setup(opts)
  },
}
```

Rules:

- One file per plugin (or one tightly-related group).
- Use `opts` (table) when the plugin exposes `setup(opts)`. Use `config = function(_, opts) ... end` only when setup needs logic.
- Never both `opts` and `config = true`.
- Every keymap in a `keys` spec must include `desc` (which-key surfaces it).
- For `keys` callbacks that need `require`, use a function — not a string command — so loading stays lazy.
- Never `require("<plugin>")` at the top of the spec file — defeats lazy-loading.

## Step 5 — Update `lazy-lock.json` deliberately

After `:Lazy sync`, the lock file gains the new entry. Stage only the new entry plus your spec file. If `lazy-lock.json` shows changes to plugins you didn't touch, split them into a separate commit — do not let unrelated churn ride along.

## Step 6 — Validate

Run `/validate` (or `make lint && make test`). All tests must pass. Fix any failures in place — never skip.

If the plugin adds public Lua API surface in `lua/yoda/`, confirm a test exists in the mirrored `tests/unit/` path.

## Step 7 — Commit

Conventional commit, `feat(plugins)` scope:

```
feat(plugins): add <plugin-name> for <purpose>

<one paragraph why — what gap this fills, why not extend an existing plugin>
```

If `lazy-lock.json` is in the same commit, that's expected for an add. If it shows unrelated changes, split first.

## Anti-patterns

- Skipping step 1 — the stability gate is non-optional.
- Pinning to a commit SHA instead of a tag (SHA only when debugging a known regression).
- `require("<plugin>")` at the top of the spec file.
- Defining keymaps in both `keys` spec and `config`/`on_attach` — pick the spec.
- Plugin config logic in `init.lua` (runs before Neovim is ready).
- Bundling a plugin add with unrelated changes. One PR = one `type(scope)`.
