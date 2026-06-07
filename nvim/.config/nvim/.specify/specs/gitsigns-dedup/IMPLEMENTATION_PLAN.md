# gitsigns-dedup — Implementation Plan

## Current State Summary
Two plugin specs both declare `vim-fugitive` and `gitsigns.nvim`. Lazy.nvim deduplicates by plugin name; since both `gitsigns.lua` and `git-stuff.lua` return a table of specs with the same plugin identifiers, only one set is loaded. Alphabetically `git-stuff.lua` loads after `gitsigns.lua`, so the keymapped variant wins. But this is accidental — a rename of either file would change behavior. The `gitsigns.lua` file is dead weight (its setup is never called). No external references to either file exist.

## Checkpoints
### CP-1: Consolidate and deduplicate ✅
- **Touches**: `lua/plugins/gitsigns.lua`, `lua/plugins/git-stuff.lua`
- **Tasks**:
  1. Rewrite `lua/plugins/gitsigns.lua` to contain: (a) `tpope/vim-fugitive` spec, (b) `lewis6991/gitsigns.nvim` spec with `setup()` + keymaps with `desc` fields
  2. Delete `lua/plugins/git-stuff.lua`
- **Verification**: `grep -rl 'tpope/vim-fugitive' lua/plugins/` returns exactly one file: `lua/plugins/gitsigns.lua`
- **Commit message**: `fix: deduplicate gitsigns + fugitive plugin specs into single file`

## Risks & Open Questions
- None. Both specs are identical for fugitive; the keymapped gitsigns config is the intended one. No external dependencies. Zero blast radius.
---
Plan ready: 1 checkpoint, ~5 minutes. Run `/skill:vox build gitsigns-dedup` to start CP-1.

Completed 2026-06-07 by /skill:vox build.
