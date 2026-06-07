# diagnostic-config — Implementation Plan

## Current State Summary
Zero `vim.diagnostic.config()` calls exist in the codebase. Diagnostics render with Neovim defaults (virtual_text=true, signs=true, underline=true, update_in_insert=false, severity_sort=false). No keymap exists for toggling virtual text. The sign column is always visible (`signcolumn=yes` in vim-options.lua), so toggling virtual_text off will leave a clean gutter-only view — this is the desired behavior.

## Checkpoints
### CP-1: Add diagnostic config and toggle keymap ✅
- **Touches**: `lua/vim-options.lua`
- **Tasks**:
  1. Add `vim.diagnostic.config({...})` call with explicit defaults + severity_sort
  2. Add `<leader>lx` keymap that toggles `virtual_text` and notifies state
- **Verification**: `grep -c 'vim.diagnostic.config' lua/vim-options.lua` returns `1`
- **Commit message**: `feat: add vim.diagnostic.config() and <leader>lx toggle`

## Risks & Open Questions
- None. Adding a config call and a keymap — zero blast radius. The toggle keeps signs column intact so it's always safe to flip.
---
Plan ready: 1 checkpoint, ~5 minutes. Run `/skill:vox build diagnostic-config` to start CP-1.

Completed 2026-06-07 by /skill:vox build.
