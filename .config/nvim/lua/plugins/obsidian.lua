

local function nmap(key, cmd, desc)
    vim.api.nvim_set_keymap('n', key, cmd, { noremap = true, silent = true, desc = desc })
end

local function keymaps()
    nmap("<leader>oo", ":ObsidianOpen<CR>", "[O]bsidian [O]pen")
    nmap("<leader>ob", ":ObsidianBacklinks<CR>", "[O]bsidian [B]acklinks")
    nmap("<leader>otd", ":ObsidianToday<CR>", "[O]bsidian [T]o[d]ay")
    nmap("<leader>os", ":ObsidianSearch<CR>", "[O]bsidian [S]earch")
    nmap("<leader>on", ":ObsidianNew<CR>", "[O]bsidian [N]ew")
    nmap("<leader>ot", ":ObsidianTemplate<CR>", "[O]bsidian [T]emplate")
    nmap("<leader>oqs", ":vsplit | :ObsidianQuickSwitch<CR>", "[O]bsidian [Q]uick[S]witch")
    nmap("<leader>ofl", ":ObsidianFollowLink<CR>", "[O]bsidian [F]ollow[L]ink")
    nmap("<leader>opi", ":ObsidianPasteImg<CR>", "[O]bsidian [P]aste[I]mg")
    nmap("<leader>oen", ":ObsidianExtractNote<CR>", "[O]bsidian [E]xtract[N]ote")
end

local opts = {
    dir = "/home/sub0x/1-projects/vaults/sub0x_vault",
    completion = {
        nvim_cmp = true,
        min_chars = 2,
    },
    templates = {
        subdir = "6-templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M:%S",
    },
    ui = {
        enable = false,
    },
}

-- Custom function to browse and insert templates
function InsertTemplate()
    local telescope = require('telescope.builtin')
    local templates_dir = '/home/sub0x/1-projects/vaults/sub0x_vault/6-templates'
    telescope.find_files({
        prompt_title = "Insert Template",
        cwd = templates_dir,
        attach_mappings = function(prompt_bufnr, map)
            local actions = require('telescope.actions')
            local actions_state = require('telescope.actions.state')

            map('i', '<CR>', function()
                local selected_entry = actions_state.get_selected_entry()
                local filename = selected_entry.value
                local file_content = vim.fn.readfile(templates_dir .. '/' .. filename)
                vim.api.nvim_put(file_content, '', true, true)
                actions.close(prompt_bufnr)
            end)

            return true
        end
    })
end

return {
    "epwalsh/obsidian.nvim",
    version = "*",
    keys = {
        { "<leader>otd", "<cmd>ObsidianToday<cr>", desc = "[O]bsidian [t]o[d]ay" },
        { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "[O]bsidian [O]pen" },
        { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "[O]bsidian [S]earch" },
        { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "[O]bsidian [N]ew" },
        { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "[O]bsidian [B]acklinks" },
        { "<leader>ote", "<cmd>ObsidianTemplate<cr>", desc = "[O]bsidian [T]emplate" },
        { "<leader>at", "<cmd>lua InsertTemplate()<cr>", desc = "[A]lt [T]emplate" },
        { "<leader>oqs", "<cmd>vsplit | ObsidianQuickSwitch<cr>", desc = "[O]bsidian [Q]uick[S]witch" },
        { "<leader>ofl", "<cmd>ObsidianFollowLink<cr>", desc = "[O]bsidian [F]ollow[L]ink" },
        { "<leader>opi", "<cmd>ObsidianPasteImg<cr>", desc = "[O]bsidian [P]aste[I]mg" },
        { "<leader>oen", "<cmd>ObsidianExtractNote<cr>", desc = "[O]bsidian [E]xtract[N]ote" },
    },
    lazy = true,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local obsidian = require("obsidian")
        obsidian.setup(opts)
        keymaps()
    end
}

