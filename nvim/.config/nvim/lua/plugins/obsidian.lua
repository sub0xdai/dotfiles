local function InsertTemplate()
    local telescope = require("telescope.builtin")
    local templates_dir = vim.fn.expand("~/1-projects/vaults/sub0x_vault/6-templates")
    telescope.find_files({
        prompt_title = "Insert Template",
        cwd = templates_dir,
        attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local actions_state = require("telescope.actions.state")
            map("i", "<CR>", function()
                local selected_entry = actions_state.get_selected_entry()
                local filename = selected_entry.value
                local file_content = vim.fn.readfile(templates_dir .. "/" .. filename)
                vim.api.nvim_put(file_content, "", true, true)
                actions.close(prompt_bufnr)
            end)
            return true
        end,
    })
end

return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    cmd = {
        "ObsidianBacklinks",
        "ObsidianDailies",
        "ObsidianExtractNote",
        "ObsidianFollowLink",
        "ObsidianLink",
        "ObsidianLinkNew",
        "ObsidianLinks",
        "ObsidianNew",
        "ObsidianNewFromTemplate",
        "ObsidianOpen",
        "ObsidianPasteImg",
        "ObsidianQuickSwitch",
        "ObsidianRename",
        "ObsidianSearch",
        "ObsidianTags",
        "ObsidianTemplate",
        "ObsidianToday",
        "ObsidianToggleCheckbox",
        "ObsidianTomorrow",
        "ObsidianTOC",
        "ObsidianYesterday",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "hrsh7th/nvim-cmp",
    },
    keys = {
        { "<leader>otd", "<cmd>ObsidianToday<cr>", desc = "[O]bsidian [t]o[d]ay" },
        { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "[O]bsidian [O]pen" },
        { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "[O]bsidian [S]earch" },
        { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "[O]bsidian [N]ew" },
        { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "[O]bsidian [B]acklinks" },
        { "<leader>ot", "<cmd>ObsidianTemplate<cr>", desc = "[O]bsidian [T]emplate" },
        { "<leader>at", "<cmd>lua InsertTemplate()<cr>", desc = "[A]lt [T]emplate" },
        { "<leader>oqs", "<cmd>vsplit | ObsidianQuickSwitch<cr>", desc = "[O]bsidian [Q]uick[S]witch" },
        { "<leader>ofl", "<cmd>ObsidianFollowLink<cr>", desc = "[O]bsidian [F]ollow[L]ink" },
        { "<leader>opi", "<cmd>ObsidianPasteImg<cr>", desc = "[O]bsidian [P]aste[I]mg" },
        { "<leader>oen", "<cmd>ObsidianExtractNote<cr>", desc = "[O]bsidian [E]xtract[N]ote" },
        { "<leader>ol", "<cmd>ObsidianLinks<cr>", desc = "[O]bsidian [L]inks" },
        { "<leader>oc", "<cmd>ObsidianToggleCheckbox<cr>", desc = "[O]bsidian toggle [c]heckbox" },
    },
    init = function()
        _G.InsertTemplate = InsertTemplate

        local group = vim.api.nvim_create_augroup("sub0x-obsidian-markdown", { clear = true })

        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = "markdown",
            callback = function(args)
                require("sub0x.core.obsidian").setup_markdown_buffer(args.buf)
            end,
        })
    end,
    opts = function()
        return require("sub0x.core.obsidian").opts()
    end,
    config = function(_, opts)
        require("obsidian").setup(opts)
        require("sub0x.core.obsidian").patch_template_substitutions()
    end,
}
