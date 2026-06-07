# treesitter-explicit — Implementation Plan

## Current State Summary
`treesitter.lua` has `auto_install = true`, `branch = "main"`, `build = ":TSUpdate"`, `highlight = { enable = true }` with only `lua` and `typst` in `ensure_installed`. No explicit `indent` config. The obsidian module (`sub0x/core/obsidian.lua`) contains a `disable_markdown_treesitter()` function (lines 68–103) that monkey-patches `vim.treesitter.start` to return `false` for markdown buffers, plus a `pcall(vim.treesitter.stop, bufnr)` call (line 250) in `setup_markdown_buffer()`. These workarounds exist because markdown is in the treesitter parser set but the user didn't want treesitter highlighting on markdown. With explicit parser loading, this becomes unnecessary — simply don't include markdown in `ensure_installed` and the monkey-patch is dead code.

## Checkpoints
### CP-1: Harden treesitter config, remove markdown monkey-patch ✅
- **Touches**: `lua/plugins/treesitter.lua`, `lua/sub0x/core/obsidian.lua`
- **Tasks**:
  1. Rewrite `lua/plugins/treesitter.lua`: remove `branch`, change `auto_install = false`, expand `ensure_installed`, add `indent = { enable = false }`
  2. `lua/sub0x/core/obsidian.lua`: delete `disable_markdown_treesitter()` function (lines 68–103), remove its call on line 239, remove `pcall(vim.treesitter.stop, bufnr)` on line 250
- **Verification**:
  ```
  grep -q 'auto_install = false' lua/plugins/treesitter.lua && \
  ! grep -q '"main"' lua/plugins/treesitter.lua && \
  grep -q 'indent.*enable.*= false' lua/plugins/treesitter.lua && \
  ! grep -q 'disable_markdown_treesitter' lua/sub0x/core/obsidian.lua && \
  ! grep -q 'pcall(vim.treesitter.stop' lua/sub0x/core/obsidian.lua && \
  echo "PASS"
  ```
- **Commit message**: `refactor: harden treesitter config, remove markdown monkey-patch`

## Risks & Open Questions
- Removing `branch = "main"` means lazy.nvim uses the default branch (which is main). This is fine — nvim-treesitter defaults to main. If stability is needed later, pin to a tag.
- Markdown treesitter is excluded from `ensure_installed` to preserve the user's intent (no treesitter on markdown). If the user later wants markdown treesitter, a single `:TSInstall markdown` is all that's needed.
- The `build = ":TSUpdate"` is kept as-is since it works with Neovim 0.11+. The spec asked about compatibility but the current build step is already correct.
---
Plan ready: 1 checkpoint, ~15 minutes. Run `/skill:vox build treesitter-explicit` to start CP-1.

Completed 2026-06-07 by /skill:vox build.
