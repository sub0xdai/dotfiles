return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false, -- must load after treesitter, and treesitter is lazy=false
    priority = 900, -- after treesitter (1000 default), before most plugins
    config = function()
      -- merge textobjects into the already-initialized treesitter setup
      require("nvim-treesitter").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["a["] = "@block.outer",
              ["i["] = "@block.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              [">f"] = "@function.outer",
              [">a"] = "@parameter.inner",
            },
            swap_previous = {
              ["<f"] = "@function.outer",
              ["<a"] = "@parameter.inner",
            },
          },
        },
      })
    end,
  },
}
