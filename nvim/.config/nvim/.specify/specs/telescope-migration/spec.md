# telescope-migration — Telescope → Snacks Picker Migration

## Summary
Replace `telescope.nvim` with `folke/snacks.nvim` pickers across the entire config. Snacks is already installed (used by yazi.nvim). Migration touches 7 files. This is the highest-effort change but pays off in reduced plugin count, faster startup, and eliminated fzf-native/telescope-zoxide/ui-select extensions.

## Functional Requirements

### FR-1: Replace telescope plugin spec with snacks picker config
- `plugins/telescope.lua` → rewrite as `plugins/picker.lua`
- No more telescope.nvim, telescope-fzf-native, telescope-ui-select, telescope-zoxide
- Use `snacks.picker` for all picker needs

### FR-2: Port all picker keymaps to snacks.picker equivalents
| Old Keymap | Old Action | New Snacks Equivalent |
|------------|-----------|----------------------|
| `<leader><leader>` | smart find (git_files or find_files) | `snacks.picker.smart()` |
| `<leader>ff` | find_files | `snacks.picker.files()` |
| `<leader>fg` | live_grep | `snacks.picker.grep()` |
| `<leader>of` | oldfiles | `snacks.picker.recent()` |
| `<leader>fb` | buffers | `snacks.picker.buffers()` |
| `<leader>fz` | current_buffer_fuzzy_find | `snacks.picker.lines()` |
| `<leader>fo` | zoxide list | `snacks.picker.zoxide()` or `snacks.picker.files({cwd="..."})` |
| `<leader>fm` | marks | `snacks.picker.marks()` |
| `<leader>gf` | git_files | `snacks.picker.git_files()` |
| `<leader>fh` | help_tags | `snacks.picker.help()` |
| `<leader>fk` | keymaps | `snacks.picker.keymaps()` |
| `<leader>fr` | lsp_references | `snacks.picker.lsp_references()` |
| `<leader>ds` | lsp_document_symbols | `snacks.picker.lsp_symbols()` |
| `<leader>fs` | lsp_dynamic_workspace_symbols | `snacks.picker.lsp_workspace_symbols()` |

### FR-3: Remove telescope-ui-select replacement
- snacks.picker provides its own `vim.ui.select` override via `snacks.picker.ui_select`

### FR-4: Remove telescope deps from dependent plugins
- `plugins/lean.lua`: remove `nvim-telescope/telescope.nvim` dependency (lean.nvim falls back to default picker)
- `plugins/obsidian.lua`: remove telescope dependency; switch obsidian picker to `"snacks"` or `nil` (default)
- `plugins/live-preview.lua`: remove telescope dependency; live-preview needs a picker — switch to snacks
- `plugins/yaml.lua`: remove telescope optional dependency

### FR-5: Update alpha dashboard buttons
- `plugins/alpha.lua`: replace Telescope calls with snacks.picker equivalents
  - "Browse Directories" (zoxide) → `snacks.picker.zoxide()` or `snacks.picker.files()`
  - "Find file" → `snacks.picker.files()`
  - "Recent" → `snacks.picker.recent()`

### FR-6: Update vim-options.lua telescope buffer keymap
- `<S-h>` currently: `Telescope buffers sort_mru=true ...` → `snacks.picker.buffers()`

### FR-7: Remove path_display helper functions
- The custom `path_display`, `split_filepath`, `normalize_path`, `is_subdirectory` functions in telescope.lua are no longer needed

### FR-8: Remove vimgrep_arguments customization
- `rg` args customization for telescope is replaced by snacks.picker's `grep` opts

### FR-9: Remove file_ignore_patterns
- Snacks picker handles this via its own config or global ripgrep config

## Acceptance Criteria
- AC-1: `telescope.nvim` is no longer a dependency (no spec file loads it)
- AC-2: All `<leader>f*`, `<leader>gf`, `<leader>ds`, `<leader>fs`, `<leader>of`, `<leader>fo` keymaps still work with snacks.picker equivalents
- AC-3: `<S-h>` opens buffer picker
- AC-4: Alpha dashboard buttons work
- AC-5: Lean infoview picker falls back gracefully (lean.nvim uses `vim.ui.select`)
- AC-6: Obsidian picker works with snacks or default
- AC-7: Live-preview picker works
- AC-8: YAML plugin loads without telescope
- AC-9: `vim.ui.select` still works (snacks.picker provides override)
- AC-10: No telescope, telescope-fzf-native, telescope-ui-select, or telescope-zoxide in lazy.nvim loaded plugins

## Affected Files
- `lua/plugins/telescope.lua` → `lua/plugins/picker.lua` (rewrite)
- `lua/plugins/lean.lua` — line 5
- `lua/plugins/obsidian.lua` — lines 51-52, picker config
- `lua/plugins/live-preview.lua` — line 5
- `lua/plugins/yaml.lua` — line 8
- `lua/plugins/alpha.lua` — dashboard button callbacks
- `lua/vim-options.lua` — `<S-h>` keymap
