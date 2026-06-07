local M = {}

local function expand(path)
    return vim.fn.expand(path)
end

local function is_dir(path)
    return vim.fn.isdirectory(path) == 1
end

local function generate_uuid()
    return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", function(c)
        local r = math.random(0, 15)
        local v = (c == "x") and r or (r % 4 + 8)
        return string.format("%x", v)
    end)
end

local function normalize_workspace(workspace)
    if type(workspace) ~= "table" or type(workspace.path) ~= "string" then
        return nil
    end

    local normalized = vim.deepcopy(workspace)
    normalized.path = expand(normalized.path)

    if not is_dir(normalized.path) then
        return nil
    end

    if type(normalized.name) ~= "string" or normalized.name == "" then
        normalized.name = vim.fs.basename(normalized.path)
    end

    return normalized
end

local function detect_vault_root()
    local candidates = {
        vim.api.nvim_buf_get_name(0),
        vim.uv.cwd(),
    }

    for _, candidate in ipairs(candidates) do
        if type(candidate) == "string" and candidate ~= "" then
            local start = candidate

            if vim.fn.filereadable(start) == 1 then
                start = vim.fs.dirname(start)
            end

            local root = vim.fs.find(".obsidian", {
                path = start,
                upward = true,
                type = "directory",
                limit = 1,
            })[1]

            if root then
                return vim.fs.dirname(root)
            end
        end
    end

    return nil
end

local function slugify(text)
    local slug = text:lower()
    slug = slug:gsub("[^a-z0-9%s-]", "")
    slug = slug:gsub("%s+", "-")
    slug = slug:gsub("%-+", "-")
    slug = slug:gsub("^%-", "")
    slug = slug:gsub("%-$", "")

    return slug
end

local function open_with_system(path)
    if vim.ui.open then
        vim.ui.open(path)
        return
    end

    vim.fn.jobstart({ "xdg-open", path }, { detach = true })
end

local function find_daily_template(workspaces)
    for _, workspace in ipairs(workspaces) do
        if type(workspace.path) == "string" then
            local template = vim.fs.joinpath(expand(workspace.path), "6-templates", "daily.md")

            if vim.fn.filereadable(template) == 1 then
                return "daily.md"
            end
        end
    end

    return nil
end

local function translate_obsidian_datetime_format(format)
    local tokens = {
        { "YYYY", "%Y" },
        { "YY", "%y" },
        { "MMMM", "%B" },
        { "MMM", "%b" },
        { "MM", "%m" },
        { "M", "%-m" },
        { "dddd", "%A" },
        { "ddd", "%a" },
        { "DD", "%d" },
        { "D", "%-d" },
        { "HH", "%H" },
        { "H", "%-H" },
        { "hh", "%I" },
        { "h", "%-I" },
        { "mm", "%M" },
        { "ss", "%S" },
        { "A", "%p" },
        { "a", "__SU0X_OBSIDIAN_LOWER_AMPM__" },
    }

    local chunks = {}
    local i = 1

    while i <= #format do
        local char = format:sub(i, i)

        if char == "[" then
            local close_idx = format:find("]", i + 1, true)

            if close_idx then
                chunks[#chunks + 1] = format:sub(i + 1, close_idx - 1)
                i = close_idx + 1
            else
                chunks[#chunks + 1] = char
                i = i + 1
            end
        else
            local matched = false

            for _, token in ipairs(tokens) do
                local source, target = token[1], token[2]

                if format:sub(i, i + #source - 1) == source then
                    chunks[#chunks + 1] = target
                    i = i + #source
                    matched = true
                    break
                end
            end

            if not matched then
                chunks[#chunks + 1] = char
                i = i + 1
            end
        end
    end

    return table.concat(chunks)
end

local function render_obsidian_datetime(format)
    local strftime_format = translate_obsidian_datetime_format(format)
    local rendered = os.date(strftime_format)

    return rendered:gsub("__SU0X_OBSIDIAN_LOWER_AMPM__", function()
        return os.date("%p"):lower()
    end)
end

function M.patch_template_substitutions()
    if vim.g.sub0x_obsidian_template_patch_applied then
        return
    end

    local ok, templates = pcall(require, "obsidian.templates")

    if not ok then
        return
    end

    local original = templates.substitute_template_variables

    templates.substitute_template_variables = function(text, client, note)
        text = text:gsub("{{date:([^}]+)}}", function(format)
            return render_obsidian_datetime(format)
        end)
        text = text:gsub("{{time:([^}]+)}}", function(format)
            return render_obsidian_datetime(format)
        end)

        return original(text, client, note)
    end

    vim.g.sub0x_obsidian_template_patch_applied = true
end

function M.setup_markdown_buffer(bufnr)
    local opt = vim.opt_local

    opt.wrap = true
    opt.linebreak = true
    opt.conceallevel = 0
    opt.concealcursor = ""
    opt.spell = false
    opt.textwidth = 100

    vim.api.nvim_buf_call(bufnr, function()
        vim.opt_local.formatoptions:append({ "n", "2" })
        vim.opt_local.formatoptions:remove("t")
    end)
end

function M.workspaces()
    if type(vim.g.obsidian_workspaces) == "table" and #vim.g.obsidian_workspaces > 0 then
        local workspaces = {}

        for _, workspace in ipairs(vim.g.obsidian_workspaces) do
            local normalized = normalize_workspace(workspace)

            if normalized then
                workspaces[#workspaces + 1] = normalized
            end
        end

        if #workspaces > 0 then
            return workspaces
        end
    end

    local fallback_vaults = {
        {
            name = "sub0x_vault",
            path = "~/1-projects/vaults/sub0x_vault",
        },
    }

    local existing = {}
    local seen = {}

    for _, workspace in ipairs(fallback_vaults) do
        local normalized = normalize_workspace(workspace)

        if normalized and not seen[normalized.path] then
            seen[normalized.path] = true
            existing[#existing + 1] = normalized
        end
    end

    local detected_root = detect_vault_root()

    if detected_root and not seen[detected_root] then
        existing[#existing + 1] = {
            name = vim.fs.basename(detected_root),
            path = detected_root,
        }
    end

    return existing
end

function M.opts()
    math.randomseed(os.time())

    local workspaces = M.workspaces()

    return {
        workspaces = workspaces,
        notes_subdir = "0-zettel",
        new_notes_location = "notes_subdir",
        preferred_link_style = "wiki",
        wiki_link_func = require("obsidian.util").wiki_link_alias_prefix,
        sort_by = "modified",
        sort_reversed = true,
        open_notes_in = "current",
        completion = {
            blink = true,
            min_chars = 2,
        },
        daily_notes = {
            folder = "5-journal",
            date_format = "%Y/%Y-%m-%d",
            alias_format = "%A, %B %-d, %Y",
            default_tags = { "daily", "journal" },
            template = find_daily_template(workspaces),
        },
        templates = {
            folder = "6-templates",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M",
            substitutions = {
                yesterday = function()
                    return os.date("%Y-%m-%d", os.time() - 86400)
                end,
                weekday = function()
                    return os.date("%A")
                end,
                cursor = function()
                    return "<++>"
                end,
            },
        },
        note_id_func = function(title)
            return generate_uuid()
        end,
        note_frontmatter_func = function(note)
            if note.title then
                note:add_alias(note.title)
            end

            local out = {
                id = note.id,
                title = note.title,
                desc = "",
                aliases = note.aliases,
                tags = note.tags,
            }

            if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                for key, value in pairs(note.metadata) do
                    out[key] = value
                end
            end

            return out
        end,
        mappings = {
            ["gf"] = {
                action = function()
                    return require("obsidian").util.gf_passthrough()
                end,
                opts = { noremap = false, expr = true, buffer = true },
            },
            ["<CR>"] = {
                action = function()
                    return require("obsidian").util.smart_action()
                end,
                opts = { buffer = true, expr = true },
            },
            ["<leader>oc"] = {
                action = function()
                    return require("obsidian").util.toggle_checkbox()
                end,
                opts = { buffer = true, desc = "Toggle checkbox" },
            },
        },
        picker = {
            name = "mini.pick",
            note_mappings = {
                new = "<C-x>",
                insert_link = "<C-l>",
            },
            tag_mappings = {
                tag_note = "<C-x>",
                insert_tag = "<C-l>",
            },
        },
        attachments = {
            img_folder = "3-resource/assets",
            img_name_func = function()
                return string.format("%s-", os.date("%Y%m%d-%H%M%S"))
            end,
        },
        follow_url_func = open_with_system,
        follow_img_func = open_with_system,
        ui = {
            enable = false,
            update_debounce = 200,
            max_file_length = 5000,
            bullets = { char = "•", hl_group = "ObsidianBullet" },
            external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
            hl_groups = {
                ObsidianTodo = { bold = true, fg = "#f78c6c" },
                ObsidianDone = { bold = true, fg = "#89ddff" },
                ObsidianRightArrow = { bold = true, fg = "#ffcb6b" },
                ObsidianTilde = { bold = true, fg = "#c3e88d" },
                ObsidianImportant = { bold = true, fg = "#ff5370" },
                ObsidianBullet = { bold = true, fg = "#82aaff" },
                ObsidianExtLinkIcon = { fg = "#89ddff" },
            },
        },
        callbacks = {
            enter_note = function()
                M.setup_markdown_buffer(0)
            end,
        },
    }
end

return M
