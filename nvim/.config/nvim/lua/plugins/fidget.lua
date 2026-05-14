return {
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      -- Minimal, brutalist aesthetic: no animation, just status text
      notification = {
        window = {
          winblend = 0, -- solid, no transparency
          border = "none", -- no border
          align = "bottom",
        },
      },
      progress = {
        display = {
          done_icon = "✓",
          done_style = "FidgetDone",
          progress_style = "FidgetProgress",
          render_limit = 16,
        },
      },
      -- LSP status in the corner, not a distraction
      integration = {
        ["nvim-tree"] = { enable = false },
        ["telescope"] = { enable = false },
      },
    },
  },
}
