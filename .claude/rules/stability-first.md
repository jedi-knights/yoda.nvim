---
description: Yoda.nvim's stability-first decision framework. Triggers on any proposal to add a plugin, regenerate `lazy-lock.json`, switch to a nightly/main branch, adopt an experimental feature, or upgrade across a major version. Defers to the Stability > Functionality > Performance > Latest Features priority order from CLAUDE.md.
---

# Stability First

Yoda.nvim is a distribution that other people depend on. Latest is not the same as best. Apply this rule before proposing any change that could destabilize the install.

## What triggers this rule

- Adding a new plugin spec under `lua/plugins/`
- Modifying or regenerating `lazy-lock.json`
- Switching a plugin from a `tag` to `branch = "main"` or `version = "*"`
- Adopting an experimental feature, nightly Neovim API, or pre-release plugin
- Upgrading a plugin across a major version
- Replacing a working tool with a "more modern" alternative purely for novelty

## Priority order (from CLAUDE.md)

**Stability > Functionality > Performance > Latest Features**

When two options conflict, choose the one higher on this list — even if it means rejecting an objectively newer or faster choice.

## Decision questions

Before proposing the change, answer these in one short block:

1. **Does this improve stability or introduce risk?** Name the specific failure mode if it goes wrong (panic on startup, broken keymap, lost session, slow first-insert).
2. **Is this proven in the community?** Look for: ≥6 months in stable release, established maintainer, recent commit activity, no open critical issues. "It's in someone's dotfiles" is not proof.
3. **Can the existing stack already do this?** Grep `lua/plugins/` for adjacent functionality. If 60%+ overlap exists, extend rather than add.
4. **What's the rollback plan?** A pinned `lazy-lock.json` is the minimum. For larger changes, name the commit to revert to.

## Mandatory behaviors

- **Pin versions.** New plugins get `tag = "vX.Y.Z"` or are tracked through `lazy-lock.json` — never a floating `branch = "main"` unless the plugin has no tagged releases.
- **Update `lazy-lock.json` intentionally.** Do not regenerate it as a side effect of unrelated work. If `lazy-lock.json` appears in the diff, it must be the *subject* of the commit, not a stowaway.
- **Validate after any plugin change.** Run `/validate` (or `make lint && make test`) before marking the work complete.
- **Document non-obvious choices.** When picking a less common plugin or pinning an older version, leave a one-line comment in the spec file explaining why.

## Output shape when this rule fires

> **Stability check** (per `.claude/rules/stability-first.md`):
> - **Risk:** <named failure mode if it breaks>
> - **Maturity:** <community signal>
> - **Existing coverage:** <what's already there, or "none">
> - **Rollback:** <git ref or revert path>
>
> Recommend: <pinned spec / extend existing / decline>. Proceed?

Keep it under 8 lines. Wait for confirmation before editing.

## Skip this rule when

- The change is a bug fix to an already-installed plugin's config (no new dependency)
- The change is a purely internal Lua refactor with no plugin surface
- The user explicitly says "just add it" or "skip the stability check"
