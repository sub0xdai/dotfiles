return {
  'karb94/neoscroll.nvim',
  config = function()
    local neoscroll = require('neoscroll')
    neoscroll.setup({
      hide_cursor = true,
      stop_eof = true,
      duration_multiplier = 1.0,
      easing = 'sine',
    })

    local mappings = {
      ['<C-u>'] = function() neoscroll.ctrl_u({ duration = 350 }) end,
      ['<C-d>'] = function() neoscroll.ctrl_d({ duration = 350 }) end,
      ['<C-b>'] = function() neoscroll.ctrl_b({ duration = 350 }) end,
      ['<C-f>'] = function() neoscroll.ctrl_f({ duration = 350 }) end,
      ['<C-y>'] = function() neoscroll.scroll(-0.10, { move_cursor = false, duration = 50 }) end,
      ['zt']    = function() neoscroll.zt({ half_win_duration = 150 }) end,
      ['zz']    = function() neoscroll.zz({ half_win_duration = 150 }) end,
      ['zb']    = function() neoscroll.zb({ half_win_duration = 150 }) end
    }

    local modes = { 'n', 'v', 'x' }
    for key, func in pairs(mappings) do
      vim.keymap.set(modes, key, func)
    end
  end,
  event = "VeryLazy"
}

