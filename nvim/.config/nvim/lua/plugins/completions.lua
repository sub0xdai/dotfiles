return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      if not cmp then
        print("cmp not loaded")
        return
      end
      -- Load snippets - using pcall to prevent errors if it fails
      pcall(function() require("luasnip.loaders.from_vscode").lazy_load() end)
      cmp.setup({
        snippet = {
          expand = function(args)
            -- Check if luasnip is available before using it
            local has_luasnip, luasnip = pcall(require, "luasnip")
            if has_luasnip then
              luasnip.lsp_expand(args.body)
            end
          end,
        },
        window = {
          -- Use simpler window config that will still give rounded borders
          completion = {
            border = "rounded",
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
          },
          documentation = {
            border = "rounded",
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
          },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-y>"] = cmp.mapping.complete(), -- Manual trigger
        }),
        sources = cmp.config.sources({
          { name = "lazydev", group_index = 0 },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        completion = {
          completeopt = 'menu,menuone,noinsert'
        }
      })
      -- Set up cmp for cmdline
      cmp.setup.cmdline(':', {
        sources = {
          { name = 'cmdline' }
        }
      })
    end,
  },
}
