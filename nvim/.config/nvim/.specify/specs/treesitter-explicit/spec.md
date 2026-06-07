# treesitter-explicit — Hardened Tree-sitter Configuration

## Summary
Tree-sitter config uses `auto_install = true` and `branch = "main"`. The obsidian module monkey-patches `vim.treesitter.start` to disable markdown highlighting — a fragile workaround. Switch to explicit parser loading, expand ensure_installed, and remove the monkey-patch.

## Functional Requirements

### FR-1: Explicit parser loading
- `auto_install` set to `false` — parsers installed explicitly via `:TSInstall`
- `branch` set to a stable tag instead of `"main"` (or removed, letting lazy.nvim use default)

### FR-2: Expanded ensure_installed
- Add parsers matching configured LSPs: go, rust, python, javascript, typescript, c, cpp, bash, zig, haskell, latex, json, yaml, toml, html, css, sql, markdown, markdown_inline, prisma, gleam, nim, wgsl

### FR-3: Explicit indent configuration
- `indent = { enable = false }` — no auto-indent from treesitter; use vim's built-in `smartindent`/`breakindent`

### FR-4: Remove markdown treesitter monkey-patch
- Delete `disable_markdown_treesitter()` function from `lua/sub0x/core/obsidian.lua`
- Remove the call to it from `setup_markdown_buffer()`
- Remove the `pcall(vim.treesitter.stop, bufnr)` call (no longer needed)
- Markdown highlighting controlled by the `ensure_installed` list (user can `:TSInstall markdown` if desired)

### FR-5: build step compatibility
- `build = ":TSUpdate"` updated to be compatible with Neovim 0.11+

## Acceptance Criteria
- AC-1: `auto_install = false` in treesitter.lua
- AC-2: `ensure_installed` includes all major languages with LSP configs
- AC-3: `indent = { enable = false }` present
- AC-4: `branch` is not `"main"` (either a tag or removed)
- AC-5: `disable_markdown_treesitter()` function no longer exists in obsidian.lua
- AC-6: `vim.treesitter.stop()` call removed from `setup_markdown_buffer()`
- AC-7: `vim.g.sub0x_disable_markdown_treesitter` variable no longer referenced

## Affected Files
- `lua/plugins/treesitter.lua` — full rewrite of setup opts
- `lua/sub0x/core/obsidian.lua` — remove monkey-patch function + call site
