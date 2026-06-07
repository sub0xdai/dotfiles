# telescope-migration — Implementation Plan

## Current State Summary
`telescope.nvim` is the central picker with 3 extensions (fzf-native, ui-select, zoxide). It's configured with custom `path_display`, `project_files()` smart finder, `vimgrep_arguments`, `file_ignore_patterns`, binary preview skip, and ~250 lines of config. Five other plugins declare telescope as a dependency: lean, obsidian, live-preview, yaml, and alpha. Two additional files use telescope commands directly: vim-options.lua (`<S-h>` buffer picker) and obsidian.lua's `InsertTemplate()` function. Snacks.nvim is already installed with `picker = { enabled = true }` but only basic config.

Snacks.picker covers every picker telescope provides: files, grep, git_files, buffers, recent, lines, zoxide (built-in), marks, help, keymaps, lsp_references, lsp_symbols, lsp_workspace_symbols, smart (git+recent+files+buffers combined), plus a built-in `vim.ui.select` override. The migration eliminates 4 plugins (telescope + 3 extensions) and ~200 lines of config while preserving all keybindings.

## Checkpoints
### CP-1: Full migration — replace telescope with snacks.picker across all 7 files ✅
- **Touches**: `lua/plugins/telescope.lua`, `lua/plugins/snacks.lua`, `lua/plugins/lean.lua`, `lua/plugins/obsidian.lua`, `lua/plugins/live-preview.lua`, `lua/plugins/yaml.lua`, `lua/plugins/alpha.lua`, `lua/vim-options.lua`, `lua/sub0x/core/obsidian.lua`
- **Tasks**:
  1. Delete `lua/plugins/telescope.lua` (entire file, 258 lines)
  2. Expand `lua/plugins/snacks.lua`: add picker ui_select config + all keymaps in `keys` table (14 keymaps)
  3. `lua/plugins/lean.lua`: remove `nvim-telescope/telescope.nvim` from deps (line 7)
  4. `lua/plugins/obsidian.lua`: remove telescope dep (line 52), rewrite `InsertTemplate()` to use Snacks.picker.files()
  5. `lua/sub0x/core/obsidian.lua`: change picker name from `"telescope.nvim"` to `nil` (uses vim.ui.select, which snacks overrides)
  6. `lua/plugins/live-preview.lua`: remove telescope dep, change `picker` from `"telescope"` to `nil`
  7. `lua/plugins/yaml.lua`: remove telescope optional dep
  8. `lua/plugins/alpha.lua`: replace `:Telescope zoxide list<CR>` with lua callback, replace `:Telescope find_files<CR>` and `:Telescope oldfiles<CR>`
  9. `lua/vim-options.lua`: replace `<S-h>` Telescope buffer command with Snacks.picker.buffers()
- **Verification**:
  ```
  ! grep -rql 'telescope\|telescope-fzf-native\|telescope-ui-select\|telescope-zoxide' lua/plugins/ && \
  test ! -f lua/plugins/telescope.lua && \
  grep -q 'ui_select' lua/plugins/snacks.lua && \
  grep -q 'smart()' lua/plugins/snacks.lua && \
  grep -q 'zoxide()' lua/plugins/snacks.lua && \
  ! grep -q 'nvim-telescope' lua/plugins/lean.lua && \
  ! grep -q 'nvim-telescope' lua/plugins/obsidian.lua && \
  ! grep -q 'nvim-telescope' lua/plugins/live-preview.lua && \
  ! grep -q 'nvim-telescope' lua/plugins/yaml.lua && \
  ! grep -q 'Telescope' lua/plugins/alpha.lua && \
  ! grep -q 'Telescope' lua/vim-options.lua && \
  ! grep -q 'telescope' lua/plugins/obsidian.lua && \
  echo "PASS"
  ```
- **Commit message**: `refactor: migrate telescope to snacks.picker across all plugins`

## Risks & Open Questions
- **InsertTemplate rewrite**: The `InsertTemplate()` function used telescope's `attach_mappings` to intercept `<CR>` and insert file content. Snacks.picker uses `confirm` callback with `item.file` — functionally equivalent but different API.
- **lean.nvim**: Uses `vim.ui.select` internally for its infoview picker when telescope isn't available. Since snacks.picker provides a `vim.ui.select` override, this fallback path is seamless.
- **live-preview.nvim**: The `picker = "telescope"` config controls which picker opens files in the preview. Setting to `nil` falls back to `vim.ui.select` which snacks overrides. This may not be identical UX (dropdown instead of full fuzzy finder) but is functional.
- **obsidian.nvim picker**: Setting `picker.name = nil` makes obsidian use `vim.ui.select` for all pickers (QuickSwitch, search, links, etc.). With snacks' ui_select override, these become snacks.picker dropdowns rather than full telescope windows. This is a UX change — the pickers will be drop-down style instead of full-screen fuzzy finders.
---
Plan ready: 1 checkpoint, ~1 hour. Run `/skill:vox build telescope-migration` to start CP-1.

Completed 2026-06-07 by /skill:vox build.
