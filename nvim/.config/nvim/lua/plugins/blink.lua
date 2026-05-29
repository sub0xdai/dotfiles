return {
  {
    "saghen/blink.cmp",
    version = "*",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
    },
    opts = {
      keymap = {
        preset = "default",
        -- Home-row cycling (in addition to default <C-n>/<C-p>)
        ["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
        ["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        -- Show documentation automatically in a floating window
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },

        -- Ghost text shows the completion inline as you type
        ghost_text = {
          enabled = true,
        },

        -- Menu columns: icon | label + description | kind name
        menu = {
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "kind" },
            },
          },
        },
      },

      -- Signature help while typing function arguments
      signature = {
        enabled = true,
        window = {
          border = "single",
        },
      },

      -- Source priority: LSP > snippets > path > buffer
      sources = {
        default = { "lsp", "snippets", "path", "buffer" },
        -- Only suggest words ≥3 chars to avoid noise
        min_keyword_length = 3,
        per_filetype = {
          -- SQL: buffer words first (dadbod queries reuse keywords), then LSP
          sql = { "lsp", "buffer", "snippets" },
          -- Markdown: buffer catches wiki links/tags from obsidian vault
          markdown = { "lsp", "buffer", "path", "snippets" },
          -- Lua: lsp + lazydev cover everything; buffer as fallback
          lua = { "lsp", "path", "snippets", "buffer" },
        },
        providers = {
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
            score_offset = 100,
          },
          path = {
            name = "Path",
            module = "blink.cmp.sources.path",
            score_offset = 10,
            opts = {
              trailing_slash = false,
              label_trailing_slash = true,
              show_hidden_files_by_default = true,
            },
          },
          snippets = {
            name = "Snippets",
            module = "blink.cmp.sources.snippets",
            score_offset = 50,
          },
          buffer = {
            name = "Buffer",
            module = "blink.cmp.sources.buffer",
            score_offset = -10,
          },
        },
      },

      -- Rust-powered fuzzy matching (compiled binary, extremely fast)
      fuzzy = {
        implementation = "prefer_rust_with_warning",
        prebuilt_binaries = {
          download = true,
        },
      },
    },
  },
}
