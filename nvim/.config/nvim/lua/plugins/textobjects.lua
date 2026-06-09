return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false,
    config = function()
      local ts_textobjects = require("nvim-treesitter-textobjects")

      ts_textobjects.setup({
        select = {
          lookahead = true,
          include_surrounding_whitespace = false,
        },
        move = {
          set_jumps = true,
        },
      })

      -- Select textobjects
      local select = require("nvim-treesitter-textobjects.select")
      vim.keymap.set({ "x", "o" }, "af", function()
        select.select_textobject("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "if", function()
        select.select_textobject("@function.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ac", function()
        select.select_textobject("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ic", function()
        select.select_textobject("@class.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "a[", function()
        select.select_textobject("@block.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "i[", function()
        select.select_textobject("@block.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "aa", function()
        select.select_textobject("@parameter.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ia", function()
        select.select_textobject("@parameter.inner", "textobjects")
      end)

      -- Move textobjects
      local move = require("nvim-treesitter-textobjects.move")
      vim.keymap.set({ "n", "x", "o" }, "]f", function()
        move.goto_next_start("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "[f", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "]c", function()
        move.goto_next_start("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "[c", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end)

      -- Swap textobjects
      local swap = require("nvim-treesitter-textobjects.swap")
      vim.keymap.set("n", ">f", function()
        swap.swap_next("@function.outer")
      end)
      vim.keymap.set("n", "<f", function()
        swap.swap_previous("@function.outer")
      end)
      vim.keymap.set("n", ">a", function()
        swap.swap_next("@parameter.inner")
      end)
      vim.keymap.set("n", "<a", function()
        swap.swap_previous("@parameter.inner")
      end)
    end,
  },
}
