return {
  {
    'chomosuke/typst-preview.nvim',
    ft = 'typst',
    build = function() require('typst-preview').update() end,
    opts = {
      -- Dependencies: the `typst-preview` binary will be auto-downloaded by the build step.
      -- Requires tinymist LSP to be running for sync.
      auto_start = false,

      -- Color inversion: keep 'never' when using a dark template like
      -- catppuccin — the document already has a dark background.
      invert_colors = 'never',
    },
    keys = {
      { '<leader>tp', '<cmd>TypstPreview<cr>',        desc = 'Typst: Start preview' },
      { '<leader>tk', '<cmd>TypstPreviewStop<cr>',       desc = 'Typst: Stop preview' },
      { '<leader>tt', '<cmd>TypstPreviewToggle<cr>',      desc = 'Typst: Toggle preview' },
      { '<leader>tr', '<cmd>TypstPreviewStop<cr><cmd>TypstPreview<cr>', desc = 'Typst: Restart preview' },
      { '<leader>ts', '<cmd>TypstPreviewSyncCursor<cr>',  desc = 'Typst: Sync cursor ↔ preview' },
    },
  },
}
