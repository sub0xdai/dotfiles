return {
  "dmtrKovalenko/fff",
  build = function()
    -- downloads a prebuilt binary or falls back to cargo build
    require("fff.download").download_or_build_binary()
  end,
  opts = {},
  lazy = false, -- the plugin lazy-initialises itself
  keys = {
    { "ff", function() require('fff').find_files() end, desc = 'Find files' },
    { "fg", function() require('fff').live_grep() end, desc = 'Live grep' },
    { "fz",
      function() require('fff').live_grep({ grep = { modes = { 'fuzzy', 'plain' } } }) end,
      desc = 'Fuzzy grep',
    },
    { "fw",
      function() require('fff').live_grep_under_cursor() end,
      mode = { 'n', 'x' },
      desc = 'Grep word under cursor',
    },
    { "<leader>ft",
      function()
        require('fff').live_grep({
          query = 'TODO|FIXME|HACK|XXX', -- @waiver TB-10: search tokens, not code debt
          grep = { modes = { 'regex' } },
        })
      end,
      desc = 'TODO/FIXME search', -- @waiver TB-10
    },
  },
}
