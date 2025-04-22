return {
  'brianhuster/live-preview.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require('livepreview.config').set({
      port = 5500,
      browser = 'default',  -- Or specify your preferred browser
      dynamic_root = true,
      sync_scroll = true,
      picker = "telescope",  -- Since you have telescope installed
    })
  end,
}
