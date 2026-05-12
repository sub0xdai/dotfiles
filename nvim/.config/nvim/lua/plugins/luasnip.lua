return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  event = "InsertEnter",
  dependencies = {
    -- Pre-made snippet library for 50+ languages
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local luasnip = require("luasnip")

    -- Load from friendly-snippets (VSCode-style snippets)
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Also load any local custom snippets from Neovim config
    require("luasnip.loaders.from_vscode").lazy_load({
      paths = { vim.fn.stdpath("config") .. "/snippets" },
    })

    -- Jump to next snippet placeholder with <C-j>
    vim.keymap.set({ "i", "s" }, "<C-j>", function()
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { silent = true })

    -- Jump to previous snippet placeholder with <C-k>
    vim.keymap.set({ "i", "s" }, "<C-k>", function()
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { silent = true })

    -- Cycle through choice nodes with <C-f>
    vim.keymap.set({ "i", "s" }, "<C-f>", function()
      if luasnip.choice_active() then
        luasnip.change_choice(1)
      end
    end, { silent = true })
  end,
}
