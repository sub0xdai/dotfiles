# diagnostic-config — Missing vim.diagnostic.config() + Virtual Text Toggle

## Summary
The audit found zero `vim.diagnostic.config()` calls. Add one with sensible defaults and a `<leader>lx` toggle to show/hide inline virtual text while preserving sign column indicators.

## Functional Requirements

### FR-1: Single vim.diagnostic.config() call
- Placed in `lua/vim-options.lua` (core settings, no new file needed)
- Configuration:
  - `virtual_text = true` (default on)
  - `signs = true` (gutter indicators)
  - `underline = true`
  - `update_in_insert = false` (don't flash while typing)
  - `severity_sort = true` (errors before warnings)

### FR-2: `<leader>lx` keymap for toggling virtual text
- Toggles `vim.diagnostic.config().virtual_text` on/off
- Notifies user of the new state ("Diagnostic virtual text: ON" / "OFF")
- Sign column indicators remain visible regardless of toggle state

## Acceptance Criteria
- AC-1: `vim.diagnostic.config()` is called once in vim-options.lua
- AC-2: `<leader>lx` toggles virtual text without hiding sign column
- AC-3: Notification confirms the toggle state
- AC-4: No duplicate diagnostic config calls elsewhere in the codebase

## Affected Files
- `lua/vim-options.lua` — add diagnostic config block + keymap
