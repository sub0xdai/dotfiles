local function generateUUID()
    return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", function(c)
        local r = math.random(0, 15)
        local v = (c == "x") and r or (r % 4 + 8)
        return string.format("%x", v)
    end)
end

local function InsertTemplate()
    local telescope = require('telescope.builtin')
    local templates_dir = vim.fn.expand('~/1-projects/vaults/sub0x_vault/6-templates')
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
    lazy = true,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",
        "nvim-telescope/telescope.nvim",
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
    },

    config = function()
        math.randomseed(os.time())
        _G.InsertTemplate = InsertTemplate

        local obsidian = require("obsidian")
        obsidian.setup({
            workspaces = {
                {
                    name = "sub0x_vault",
                    path = "~/1-projects/vaults/sub0x_vault",
                },
            },
            note_id_func = function(title)
              return title and title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower() or generateUUID()
              end,
            note_frontmatter_func = function(note)
                local out = {
                    id = generateUUID(),
                    title = note.title,
                    desc = "",
                    tags = note.tags,
                    alias = note.aliases,
                }
                return out
            end,
            preferred_link_style = "wiki",
            wiki_link_func = require("obsidian.util").wiki_link_alias_prefix,
            completion = {
                nvim_cmp = true,
                min_chars = 2,
            },
            templates = {
                folder = "6-templates",
                date_format = "%Y-%m-%d",
                time_format = "%H:%M:%S",
                substitutions = {
                    yesterday = function()
                        return os.date("%Y-%m-%d", os.time() - 86400)
                    end,
                },
            },
            attachments = {
                img_folder = "3-resource/assets",
            },
            notes_subdir = "0-zettel",
            ui = {
                enable = true,
                update_debounce = 200,
                checkboxes = {
                    [" "] = { char = "☐", hl_group = "ObsidianTodo" },
                    ["x"] = { char = "✔", hl_group = "ObsidianDone" },
                    [">"] = { char = "▶", hl_group = "ObsidianRightArrow" },
                    ["~"] = { char = "↺", hl_group = "ObsidianTilde" },
                },
                external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
            },
            picker = {
                name = "telescope.nvim",
            },
            sort_by = "modified",
            sort_reversed = true,
            open_notes_in = "current",
        })
    end,
}
