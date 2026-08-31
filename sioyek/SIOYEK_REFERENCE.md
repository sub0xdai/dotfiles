# Sioyek Reference (m0xu config)

Reference for sioyek usage, tailored to the config in this repo.
Fetch this file when the user asks "how do I X in sioyek" or "what is the sioyek command for X".

## Config in this repo

Files:
- `~/.config/sioyek/keys_user.config` (installed from `.config/sioyek/keys_user.config` here)
- `~/.config/sioyek/prefs_user.config` (installed from `.config/sioyek/prefs_user.config` here)

User config overrides the sioyek defaults. Commands not touched by the user config keep their default bindings.

### Custom keybindings (from keys_user.config)

| Command | Key | Default it replaced |
|---------|-----|---------------------|
| `screen_down` | `d` | space, pagedown |
| `screen_up` | `u` | S-space, pageup |
| `next_page` | `<C-f>` | C-pagedown |
| `previous_page` | `<C-b>` | C-pageup |

Gotchas from these overrides:
- `<C-f>` used to open search (default `search` binding). It is now `next_page`. Use `/` to search.
- `d`/`u` are one-screen scrolls, not half-screen.
- `<C-b>` is page up, not the vim "beginning" style behavior.

### Custom preferences (from prefs_user.config)

- `ui_font JetBrainsMono Nerd Font`
- `copy_on_select 1` - selecting text with the mouse copies it to the clipboard automatically.
- Monochrome AMOLED theme: pure black background (`#000000`), all highlight colors grayscale, dark UI chrome.
- `toggle_custom_color` / `custom_background_color` / `custom_text_color` are disabled (document colors stay controlled by the PDF).

## How sioyek input works

- Every key press executes a command. Bindings are `command key` lines in `keys_user.config`.
- Key syntax: `k`, `K` (shift), `<C-k>`, `<A-k>`, `<C-S-k>`, sequences like `gg`, `gt`, `gc`, `gC`.
- Press `:` to open a searchable list of all commands (including unbound ones).
- Commands can take number prefixes, e.g. `42gg` (page 42), `15n` (15th next search match).
- Shell commands run from sioyek via `execute` (no default binding, reachable via `:` menu). Placeholders: `%1` full path of current file, `%2` file name, `%3` selected text.
- Custom commands can be defined in `prefs_user.config` with `new_command _name cmd %1 %2` and bound in `keys_user.config`.
- CLI: `sioyek file.pdf`, `--new-window`, `--execute-command <cmd>`, `--execute-command-data "data"`.

## Basic usage

### Opening files
- `o` - file browser (`open_document`)
- `O` - searchable list of recently opened files (`open_prev_doc`); `delete` removes from list
- `<C-o>` - embedded file browser (`open_document_embedded`)
- `<C-S-o>` - embedded browser rooted at current document's folder
- Drag and drop a PDF into the window
- `sioyek file.pdf` from the command line
- `<C-t>` - new sioyek window; `<C-w>` - close window

### Navigation
- Arrow keys and mouse wheel - scroll (`move_down`, `move_up`, `move_left`, `move_right`)
- `d` / `u` - scroll down / up one screen (user config)
- `<C-f>` / `<C-b>` - next / previous page (user config)
- `space` / `S-space` - screen down / up (defaults still apply)
- `gg` - first page; `G` - last page
- `42gg` - go to page 42; `HOME` - prompt for a page number
- `t` - searchable table of contents / outline (`goto_toc`)
- `gc` - next chapter; `gC` - previous chapter
- `^` - left side of page ignoring margins; `$` - right side
- `zz` - top-right of page (useful for two-column documents)
- `backspace` / `S-backspace` - history back / forward (also `<C-left>` / `<C-right>`)
- `w` - pop viewing state (unbound by default, in `:` menu)

### Zoom
- `+` - zoom in; `-` - zoom out; `<C-wheel>` also zooms
- `=` - fit page to window width
- `<f9>` - fit to page width; `<f10>` - fit to page width ignoring margins
- `r` - rotate clockwise; `R` - rotate counterclockwise

## Advanced usage

### Search
- `/` - search (note: `<C-f>` no longer triggers search, see config gotchas)
- `n` - next match; `N` - previous match; `15n` - skip 15 matches
- `c/` - search only current chapter (`chapter_search`)
- `<begin,end>term` - search only pages begin..end, e.g. `<20,30>Figure`
- `regex_search` - regex search (via `:` menu)
- `overview_next_item` / `overview_prev_item` - show search results in overview window instead of jumping

### Overview and SmartJump
- Right-click on a reference like "Figure 2.19" - opens an overview window previewing the destination
- Middle-click - jump directly to the destination
- `l` - overview of the reference on the highlighted line (`overview_definition`)
- `<C-]>` - jump to the definition on the highlighted line (`goto_definition`)
- `]` - create a portal to the definition (`portal_to_definition`)
- `F` - keyboard smart jump; `v` - keyboard text selection

### Visual mark (ruler)
- Right-click a line of text - places a visual highlight (the "visual mark") below it
- `j` / `k` - move the visual mark down / up one line
- `` ` `` then right-click (or `` ` `` again) - return to the visual mark location
- `<f7>` - toggle visual scroll mode (mouse wheel moves the ruler instead of the page)
- `l` on a highlighted line - overview of the first reference in that line

### Marks
- `m` + letter - set a mark, e.g. `ma`
- `` ` `` + letter - go to a mark, e.g. `` `a ``
- Lowercase marks are local to the document; uppercase marks are global across sioyek
- Marks persist across sessions

### Bookmarks (named)
- `b` - add a bookmark with a text description
- `gb` - searchable list of bookmarks in current document
- `gB` - searchable list of bookmarks in all documents
- `db` - delete the bookmark closest to current location

### Highlights
- Select text, then `h` + letter - highlight with that type, e.g. `ha`
- `gh` - list of highlights in current document; `gH` - across all documents
- `gnh` / `gNh` - next / previous highlight
- `dh` - delete a highlight after left-clicking it
- `toggle_select_highlight` - select highlight mode: selected text is auto-highlighted
- `embed_annotations` - export a PDF copy with highlights/bookmarks embedded for other readers

### Portals (persistent links between two locations)
- `p` at the source location, navigate to the destination, `p` again - creates a portal
- `p` then click a PDF link - portal from the link to its destination
- `<tab>` or `gp` - jump to portal destination; `P` - edit portal destination
- `dp` - delete closest portal
- `<f12>` - toggle the helper window that shows portal destinations (useful with a second monitor)

### Command menu and config files
- `:` - searchable command list (the catch-all for anything unbound)
- `keys_user` / `prefs_user` - open user config files (via `:` menu)
- `keys` / `prefs` - open default config files
- `prefs_user_all` / `keys_user_all` - list all discovered config files

### External search
- Select text, then `s` + letter - search it with the engine mapped to that letter
- Middle-click on a paper/book name - auto-search (sioyek guesses the name)
- Engines configured via `search_url_<letter>` in `prefs_user.config`; middle-click engine via `middle_click_search_engine`

### LaTeX / Synctex
- `<f4>` - toggle synctex mode; right-click then opens the source `.tex` at the right line
- `inverse_search_command` in `prefs_user.config` sets the editor command (vim/vscode examples in official docs)
- CLI flags: `--inverse-search "<cmd> %1:%2"`, `--forward-search-file`, `--forward-search-line`

### Modes and toggles
- `<f1>` - toggle PDF link highlighting
- `<f4>` - synctex mode
- `<f5>` - presentation mode (one page fills the window)
- `<f6>` - mouse drag mode (drag pans instead of selecting)
- `<f7>` - visual scroll mode
- `<f8>` - dark mode (inverted colors)
- `<f11>` - fullscreen
- `<f12>` - helper window for portals
- `toggle_scrollbar` - enable/disable the scrollbar (off by default)
- `toggle_fastread` - highlights first characters of words (experimental)
- `toggle_smooth_scroll_mode`, `toggle_statusbar`, `toggle_titlebar`, `toggle_horizontal_scroll_lock`

### Data and sync
- Data lives in `local.db` (machine-specific: file paths) and `shared.db` (marks, bookmarks, portals, highlights)
- `shared_database_path` in `prefs_user.config` - point at a synced folder (e.g. Dropbox) to sync annotations across machines
- `export` / `import` - move data to/from json (via `:` menu)

## Quick lookup: "how do I..."

| Intent | Keys / command |
|--------|----------------|
| Jump to page 42 | `42gg` or `HOME` |
| Jump to chapter 1 | `t` (ToC) or `gc`/`gC` or `Ngg` |
| Open a file | `o`, `O`, `<C-o>`, drag-drop |
| Search text | `/`, then `n` / `N` |
| Search only this chapter | `c/` |
| Scroll down / up | `d` / `u` |
| Next / previous page | `<C-f>` / `<C-b>` |
| Zoom in / out | `+` / `-` |
| Fit page to width | `=` or `<f9>` |
| Back / forward in history | `backspace` / `S-backspace` |
| Return to last read line | right-click a line, then `` ` `` |
| Mark a spot | `m` + letter, return with `` ` `` + letter |
| Bookmark with a name | `b`, list with `gb`, all docs `gB` |
| Highlight text | select + `h` + letter |
| Jump to a highlighted line | `gh` |
| Link two spots (portal) | `p` ... `p`, view in `<f12>` window |
| Copy text | select (auto-copies with `copy_on_select 1`), or `<C-c>` |
| Open a PDF link by keyboard | `f` + number |
| Select text by keyboard | `v` + labels |
| Run any sioyek command | `:` |
| Run a shell command | `:` menu, `execute` |
| Search selected text on the web | select + `s` + letter |
| LaTeX forward/inverse search | `<f4>` synctex mode |
| Quit | `q` |
