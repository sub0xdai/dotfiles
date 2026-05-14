-- ════════════════════════════════════════════════════════════════════════════
-- Shared utilities for cool_stuff language modules
-- ════════════════════════════════════════════════════════════════════════════

local M = {}

--- Show a notification
---@param msg string
---@param level? integer
function M.notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO)
end

--- Run a command asynchronously via vim.system
---@param cmd string[]  Command + args (no nils allowed)
---@param opts? {on_exit?: fun(result: vim.SystemCompleted), cwd?: string}
function M.run_cmd(cmd, opts)
    opts = opts or {}
    local on_exit = opts.on_exit or function() end
    local cwd = opts.cwd or vim.fn.getcwd()

    -- Filter out any nil entries (safety belt)
    local filtered = {}
    for _, v in ipairs(cmd) do
        if v ~= nil then
            table.insert(filtered, v)
        end
    end

    vim.system(filtered, { text = true, cwd = cwd }, function(result)
        vim.schedule(function()
            on_exit(result)
        end)
    end)
end

--- Find project root by walking up the directory tree looking for a marker file.
---@param marker string  Filename to look for (e.g. "go.mod", "Cargo.toml", "build.zig")
---@return string  Directory containing the marker, or cwd as fallback
function M.get_project_root(marker)
    local filepath = vim.api.nvim_buf_get_name(0)
    local dir = vim.fn.fnamemodify(filepath, ":h")
    while dir ~= "/" do
        if vim.fn.filereadable(dir .. "/" .. marker) == 1 then
            return dir
        end
        dir = vim.fn.fnamemodify(dir, ":h")
    end
    return vim.fn.getcwd()
end

--- Open a command in a terminal split. Handles arg quoting via table.
---@param cmd string[]  Command + args
---@param cwd? string
function M.terminal(cmd, cwd)
    local cwd_part = cwd and ("cd " .. vim.fn.shellescape(cwd) .. " && ") or ""
    local quoted = {}
    for _, part in ipairs(cmd) do
        table.insert(quoted, vim.fn.shellescape(part))
    end
    vim.cmd("split | terminal " .. cwd_part .. table.concat(quoted, " "))
end

--- Open a raw command string in a terminal split (for commands already built as strings).
---@param cmd_str string
function M.terminal_raw(cmd_str)
    vim.cmd("split | terminal " .. cmd_str)
end

return M
