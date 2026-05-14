-- ════════════════════════════════════════════════════════════════════════════
-- Zig Tools - Custom commands for Zig development
-- ════════════════════════════════════════════════════════════════════════════

local U = require("cool_stuff.utils")

local function zig_root()
    return U.get_project_root("build.zig")
end

-- ════════════════════════════════════════════════════════════════════════════
-- Build & Run
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("ZigBuild", function(opts)
    local args = opts.args ~= "" and opts.args or ""
    U.terminal_raw("zig build " .. args)
end, { nargs = "?", desc = "zig build" })

vim.api.nvim_create_user_command("ZigBuildRelease", function()
    U.terminal_raw("zig build -Doptimize=ReleaseFast")
end, { desc = "zig build -Doptimize=ReleaseFast" })

vim.api.nvim_create_user_command("ZigBuildSafe", function()
    U.terminal_raw("zig build -Doptimize=ReleaseSafe")
end, { desc = "zig build -Doptimize=ReleaseSafe" })

vim.api.nvim_create_user_command("ZigRun", function(opts)
    local args = opts.args ~= "" and " -- " .. opts.args or ""
    U.terminal_raw("zig build run" .. args)
end, { nargs = "?", desc = "zig build run" })

vim.api.nvim_create_user_command("ZigRunFile", function(opts)
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath == "" then
        U.notify("Buffer has no file path", vim.log.levels.ERROR)
        return
    end
    local args = opts.args ~= "" and " -- " .. opts.args or ""
    U.terminal_raw("zig run " .. filepath .. args)
end, { nargs = "?", desc = "zig run <current file>" })

-- ════════════════════════════════════════════════════════════════════════════
-- Testing
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("ZigTest", function(opts)
    local args = opts.args ~= "" and opts.args or ""
    U.terminal_raw("zig build test " .. args)
end, { nargs = "?", desc = "zig build test" })

vim.api.nvim_create_user_command("ZigTestFile", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath == "" then
        U.notify("Buffer has no file path", vim.log.levels.ERROR)
        return
    end
    U.terminal_raw("zig test " .. filepath)
end, { desc = "zig test <current file>" })

vim.api.nvim_create_user_command("ZigTestFilter", function(opts)
    if opts.args == "" then
        U.notify("Usage: ZigTestFilter <test_name>", vim.log.levels.WARN)
        return
    end
    U.terminal_raw("zig build test -- --test-filter " .. opts.args)
end, { nargs = 1, desc = "zig build test with filter" })

-- ════════════════════════════════════════════════════════════════════════════
-- Code Quality
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("ZigFmt", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath == "" then
        U.notify("Buffer has no file path", vim.log.levels.ERROR)
        return
    end
    U.notify("Running: zig fmt")
    U.run_cmd({ "zig", "fmt", filepath }, {
        on_exit = function(result)
            if result.code == 0 then
                vim.cmd("checktime")
                U.notify("zig fmt: completed")
            else
                U.notify("zig fmt failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { desc = "zig fmt <current file>" })

vim.api.nvim_create_user_command("ZigFmtAll", function()
    U.notify("Running: zig fmt on project")
    U.run_cmd({ "zig", "fmt", "." }, {
        cwd = zig_root(),
        on_exit = function(result)
            if result.code == 0 then
                vim.cmd("checktime")
                U.notify("zig fmt: completed")
            else
                U.notify("zig fmt failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { desc = "zig fmt on project" })

vim.api.nvim_create_user_command("ZigFmtCheck", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath == "" then
        U.notify("Buffer has no file path", vim.log.levels.ERROR)
        return
    end
    U.notify("Running: zig fmt --check")
    U.run_cmd({ "zig", "fmt", "--check", filepath }, {
        on_exit = function(result)
            if result.code == 0 then
                U.notify("zig fmt --check: OK")
            else
                U.notify("zig fmt --check: formatting needed", vim.log.levels.WARN)
            end
        end,
    })
end, { desc = "zig fmt --check" })

-- ════════════════════════════════════════════════════════════════════════════
-- Project Management
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("ZigInit", function()
    U.notify("Running: zig init")
    U.run_cmd({ "zig", "init" }, {
        on_exit = function(result)
            if result.code == 0 then
                U.notify("zig init: completed")
                vim.cmd("checktime")
            else
                U.notify("zig init failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { desc = "zig init" })

vim.api.nvim_create_user_command("ZigFetch", function(opts)
    if opts.args == "" then
        U.notify("Usage: ZigFetch <url>", vim.log.levels.WARN)
        return
    end
    U.notify("Running: zig fetch " .. opts.args)
    U.run_cmd({ "zig", "fetch", opts.args }, {
        cwd = zig_root(),
        on_exit = function(result)
            if result.code == 0 then
                local hash = result.stdout:gsub("%s+", "")
                U.notify("Hash: " .. hash)
                vim.fn.setreg("+", hash)
                U.notify("Hash copied to clipboard")
            else
                U.notify("zig fetch failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { nargs = 1, desc = "zig fetch <url>" })

-- ════════════════════════════════════════════════════════════════════════════
-- Documentation & Help
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("ZigDoc", function(opts)
    local query = opts.args ~= "" and opts.args or ""
    local url = "https://ziglang.org/documentation/master/"
    if query ~= "" then
        url = url .. "#" .. query
    end
    local open_cmd = vim.fn.has("mac") == 1 and "open" or "xdg-open"
    vim.fn.system({ open_cmd, url })
    U.notify("Opening: " .. url)
end, { nargs = "?", desc = "Open Zig documentation" })

vim.api.nvim_create_user_command("ZigStdDoc", function(opts)
    local query = opts.args ~= "" and opts.args or ""
    local url = "https://ziglang.org/documentation/master/std/"
    if query ~= "" then
        url = url .. "#" .. query
    end
    local open_cmd = vim.fn.has("mac") == 1 and "open" or "xdg-open"
    vim.fn.system({ open_cmd, url })
    U.notify("Opening: " .. url)
end, { nargs = "?", desc = "Open Zig std lib documentation" })

vim.api.nvim_create_user_command("ZigHelp", function(opts)
    local args = opts.args ~= "" and opts.args or ""
    U.terminal_raw("zig help " .. args)
end, { nargs = "?", desc = "zig help" })

vim.api.nvim_create_user_command("ZigVersion", function()
    U.run_cmd({ "zig", "version" }, {
        on_exit = function(result)
            if result.code == 0 then
                U.notify("Zig version: " .. vim.trim(result.stdout))
            else
                U.notify("Failed to get version", vim.log.levels.ERROR)
            end
        end,
    })
end, { desc = "zig version" })

-- ════════════════════════════════════════════════════════════════════════════
-- Compilation & Analysis
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("ZigAst", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath == "" then
        U.notify("Buffer has no file path", vim.log.levels.ERROR)
        return
    end
    U.terminal_raw("zig ast-check " .. filepath)
end, { desc = "zig ast-check <current file>" })

vim.api.nvim_create_user_command("ZigTranslateC", function(opts)
    if opts.args == "" then
        U.notify("Usage: ZigTranslateC <header.h>", vim.log.levels.WARN)
        return
    end
    U.terminal_raw("zig translate-c " .. opts.args)
end, { nargs = 1, desc = "zig translate-c <header>" })

-- ════════════════════════════════════════════════════════════════════════════
-- Build Steps
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("ZigBuildSteps", function()
    U.terminal_raw("zig build --help")
end, { desc = "Show available build steps" })

vim.api.nvim_create_user_command("ZigBuildStep", function(opts)
    if opts.args == "" then
        U.notify("Usage: ZigBuildStep <step>", vim.log.levels.WARN)
        return
    end
    U.terminal_raw("zig build " .. opts.args)
end, { nargs = 1, desc = "zig build <step>" })

-- ════════════════════════════════════════════════════════════════════════════
-- Navigation
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("ZigAlt", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    local filename = vim.fn.fnamemodify(filepath, ":t:r")
    local dir = vim.fn.fnamemodify(filepath, ":h")

    if filename:match("_test$") or filename == "test" then
        local source = filepath:gsub("_test%.zig$", ".zig")
        if source == filepath then
            source = dir .. "/main.zig"
        end
        if vim.fn.filereadable(source) == 1 then
            vim.cmd("edit " .. source)
        else
            U.notify("Source file not found", vim.log.levels.WARN)
        end
    else
        local test_file = filepath:gsub("%.zig$", "_test.zig")
        local test_dir = dir .. "/test.zig"
        if vim.fn.filereadable(test_file) == 1 then
            vim.cmd("edit " .. test_file)
        elseif vim.fn.filereadable(test_dir) == 1 then
            vim.cmd("edit " .. test_dir)
        else
            U.notify("Test file not found: " .. test_file, vim.log.levels.WARN)
        end
    end
end, { desc = "Switch between source and test file" })

vim.api.nvim_create_user_command("ZigAltV", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    local filename = vim.fn.fnamemodify(filepath, ":t:r")
    local dir = vim.fn.fnamemodify(filepath, ":h")

    if filename:match("_test$") or filename == "test" then
        local source = filepath:gsub("_test%.zig$", ".zig")
        if source == filepath then
            source = dir .. "/main.zig"
        end
        if vim.fn.filereadable(source) == 1 then
            vim.cmd("vsplit " .. source)
        else
            U.notify("Source file not found", vim.log.levels.WARN)
        end
    else
        local test_file = filepath:gsub("%.zig$", "_test.zig")
        if vim.fn.filereadable(test_file) == 1 then
            vim.cmd("vsplit " .. test_file)
        else
            U.notify("Test file not found: " .. test_file, vim.log.levels.WARN)
        end
    end
end, { desc = "Switch to alt file in vsplit" })

-- ════════════════════════════════════════════════════════════════════════════
-- Suggested keymaps (uncomment and adjust to taste)
-- ════════════════════════════════════════════════════════════════════════════
-- vim.keymap.set("n", "<leader>zb", "<cmd>ZigBuild<cr>", { desc = "Zig Build" })
-- vim.keymap.set("n", "<leader>zr", "<cmd>ZigRun<cr>", { desc = "Zig Run" })
-- vim.keymap.set("n", "<leader>zt", "<cmd>ZigTest<cr>", { desc = "Zig Test" })
-- vim.keymap.set("n", "<leader>ztf", "<cmd>ZigTestFile<cr>", { desc = "Zig Test File" })
-- vim.keymap.set("n", "<leader>zf", "<cmd>ZigFmt<cr>", { desc = "Zig Fmt" })
-- vim.keymap.set("n", "<leader>za", "<cmd>ZigAlt<cr>", { desc = "Zig Alt File" })
-- vim.keymap.set("n", "<leader>zav", "<cmd>ZigAltV<cr>", { desc = "Zig Alt File (vsplit)" })
-- vim.keymap.set("n", "<leader>zv", "<cmd>ZigVersion<cr>", { desc = "Zig Version" })
