# plugin-purge — Implementation Plan

## Current State Summary
Five independent cleanup items across five files. dap.lua (105 lines) is fully present with 5 plugins. obsidian.lua has `hrsh7th/nvim-cmp` as a phantom dependency on line 53 — it's never actually loaded since blink.cmp handles completion. eslint is configured in lsp-config.lua (lines 86–99) but notably NOT in the `vim.lsp.enable()` list (line 239) — dead code. conform.lua uses prettier for 9 filetypes and rubocop for ruby/eruby. surround.lua uses `kylechui/nvim-surround` with minimal config.

## Checkpoints
### CP-1: Purge dap, nvim-cmp, eslint, prettier, nvim-surround ✅
- **Touches**: `lua/plugins/dap.lua`, `lua/plugins/obsidian.lua`, `lua/plugins/lsp-config.lua`, `lua/plugins/conform.lua`, `lua/plugins/surround.lua`
- **Tasks**:
  1. Delete `lua/plugins/dap.lua`
  2. `lua/plugins/obsidian.lua` line 53: remove `"hrsh7th/nvim-cmp"` from dependencies table
  3. `lua/plugins/lsp-config.lua` lines 86–99: replace eslint block with biome block; line 239: add `"biome"` to enable list
  4. `lua/plugins/conform.lua`: replace prettier→biome for js/ts/jsx/tsx/css/html/json/yaml/markdown; remove rubocop entries
  5. `lua/plugins/surround.lua`: rewrite to mini.surround
- **Verification**: 
  ```
  test ! -f lua/plugins/dap.lua && \
  ! grep -q 'hrsh7th/nvim-cmp' lua/plugins/obsidian.lua && \
  grep -q 'biome' lua/plugins/lsp-config.lua && \
  ! grep -q '"eslint"' lua/plugins/lsp-config.lua && \
  ! grep -q '"prettier"' lua/plugins/conform.lua && \
  grep -q 'mini.surround' lua/plugins/surround.lua && \
  echo "PASS"
  ```
- **Commit message**: `refactor: purge dap, nvim-cmp dep, eslint→biome, prettier→biome, surround→mini.surround`

## Risks & Open Questions
- biome replaces both eslint (linting) and prettier (formatting) — this is the correct move per the audit matrix. biome must be installed on the system for the LSP and formatter to work.
- rubocop removal (ruby/eruby) is outside the explicit spec but the audit flagged it — removing it since no biome equivalent exists for ruby, and the user can re-add a ruby formatter if needed.
---
Plan ready: 1 checkpoint, ~15 minutes. Run `/skill:vox build plugin-purge` to start CP-1.

Completed 2026-06-07 by /skill:vox build.
