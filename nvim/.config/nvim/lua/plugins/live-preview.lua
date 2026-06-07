return {
  'brianhuster/live-preview.nvim',
  config = function()
    require('livepreview.config').set({
      port = 5500,
      browser = 'default',
      dynamic_root = true,
      sync_scroll = true,
    })
  end,
}
