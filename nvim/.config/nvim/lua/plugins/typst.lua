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
      -- HTML live preview (tinymist)
      { '<leader>tp', '<cmd>TypstPreview<cr>',        desc = 'Typst: Start preview' },
      { '<leader>tk', '<cmd>TypstPreviewStop<cr>',       desc = 'Typst: Stop preview' },
      { '<leader>tt', '<cmd>TypstPreviewToggle<cr>',      desc = 'Typst: Toggle preview' },
      { '<leader>tr', '<cmd>TypstPreviewStop<cr><cmd>TypstPreview<cr>', desc = 'Typst: Restart preview' },
      { '<leader>ts', '<cmd>TypstPreviewSyncCursor<cr>',  desc = 'Typst: Sync cursor ↔ preview' },
      -- PDF pipeline → Sioyek (run `typst watch file.typ file.pdf` in a terminal first)
      { '<leader>tc', '<cmd>!typst compile % %:r.pdf<cr>',        desc = 'Typst: Compile once → PDF' },
      { '<leader>to', '<cmd>!sioyek %:r.pdf &>/dev/null &<cr>',   desc = 'Typst: Open PDF in Sioyek' },
    },
    -- Skeleton: auto-inject #import/#show template on new .typ files
    -- Runs at startup (ft=typst defers the *plugin*; init always runs immediately).
    init = function()
      vim.api.nvim_create_autocmd('BufNewFile', {
        pattern = '*.typ',
        group = vim.api.nvim_create_augroup('TypstSkeleton', { clear = true }),
        callback = function()
          local template = {
            '#import "@local/stoic:1.0.0": stoic-doc',
            '#show: stoic-doc',
            '',
            '= ',
            '',
          }
          vim.api.nvim_buf_set_lines(0, 0, -1, false, template)
          vim.api.nvim_win_set_cursor(0, { 4, 2 })
        end,
      })
    end,
  },
}
