# gitsigns-dedup — Git Plugin Deduplication

## Summary
Two files (`gitsigns.lua`, `git-stuff.lua`) both declare `tpope/vim-fugitive` and `lewis6991/gitsigns.nvim`. The config with keymaps (`git-stuff.lua`) wins the lazy.nvim dedup race, but the architecture is fragile and unclear. Consolidate into one file with clean separation.

## Functional Requirements

### FR-1: Single source of truth for git plugins
- `plugins/gitsigns.lua` is renamed to `plugins/git.lua` and owns both fugitive and gitsigns specs
- `plugins/git-stuff.lua` is deleted

### FR-2: Gitsigns keymaps preserved
- `<leader>gp` → `:Gitsigns preview_hunk<CR>` with `desc = "Preview hunk"`
- `<leader>gt` → `:Gitsigns toggle_current_line_blame<CR>` with `desc = "Toggle blame"`

### FR-3: Fugitive spec preserved
- `tpope/vim-fugitive` remains available (no lazy loading by default)

## Acceptance Criteria
- AC-1: `gitsigns.lua` is renamed to `git.lua`, contains only fugitive + gitsigns
- AC-2: `git-stuff.lua` no longer exists
- AC-3: `<leader>gp` and `<leader>gt` keymaps still function
- AC-4: `:Gitsigns` and `:Git` commands available
- AC-5: No duplicate plugin specs for fugitive or gitsigns anywhere in the codebase

## Affected Files
- `lua/plugins/gitsigns.lua` → rename to `lua/plugins/git.lua` + rewrite
- `lua/plugins/git-stuff.lua` → delete
