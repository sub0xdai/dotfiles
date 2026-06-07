# plugin-purge — Audit-Driven Cleanup

## Summary
Apply the audit's deprecation/purge directives: delete nvim-dap ecosystem, remove phantom nvim-cmp dependency, swap eslint→biome, swap nvim-surround→mini.surround.

## Functional Requirements

### FR-1: Delete nvim-dap ecosystem
- `plugins/dap.lua` deleted entirely
- Removes: nvim-dap, nvim-dap-go, nvim-dap-ui, nvim-dap-virtual-text, nvim-nio
- Removes keymaps: F1–F5, F13, space+b, space+gb, space+?

### FR-2: Remove phantom nvim-cmp dependency
- `plugins/obsidian.lua` line 53: remove `"hrsh7th/nvim-cmp"` from dependencies
- Obsidian completion via blink.cmp is the default; no config change needed

### FR-3: eslint → biome in LSP config
- `plugins/lsp-config.lua`: replace the eslint `vim.lsp.config("eslint", ...)` block with `vim.lsp.config("biome", ...)`
- biome cmd: `{ "biome", "lsp-proxy" }`
- biome filetypes: javascript, javascriptreact, typescript, typescriptreact, json, jsonc, css
- biome root_markers: biome.json, biome.jsonc
- Remove eslint from the `vim.lsp.enable({...})` list, add biome

### FR-4: prettier → biome in conform
- `plugins/conform.lua`: replace all `prettier` formatter entries with `biome` for: javascript, typescript, javascriptreact, typescriptreact, css, html, json, yaml, markdown
- Also remove `rubocop` entries (ruby/eruby) if present — outside audit scope but noted

### FR-5: nvim-surround → mini.surround
- `plugins/surround.lua`: replace `kylechui/nvim-surround` with `echasnovski/mini.surround`
- Default mappings preserved (ys, ds, cs — mini.surround uses same defaults)

## Acceptance Criteria
- AC-1: `plugins/dap.lua` does not exist
- AC-2: obsidian.lua dependencies do not include `hrsh7th/nvim-cmp`
- AC-3: lsp-config.lua has biome, not eslint
- AC-4: conform.lua uses biome, not prettier (for js/ts/css/html/json/yaml/markdown)
- AC-5: surround.lua uses mini.surround
- AC-6: No F-key DAP keymaps remain in the config

## Affected Files
- `lua/plugins/dap.lua` — DELETE
- `lua/plugins/obsidian.lua` — line 53
- `lua/plugins/lsp-config.lua` — eslint block (~lines 86–103), enable list
- `lua/plugins/conform.lua` — formatters_by_ft table
- `lua/plugins/surround.lua` — entire file
