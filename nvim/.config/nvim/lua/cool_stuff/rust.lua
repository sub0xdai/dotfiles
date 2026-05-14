-- ════════════════════════════════════════════════════════════════════════════
-- Rust Tools - Custom commands for Rust development
-- ════════════════════════════════════════════════════════════════════════════

local U = require("cool_stuff.utils")

local function cargo_root()
    return U.get_project_root("Cargo.toml")
end

-- ════════════════════════════════════════════════════════════════════════════
-- Build & Run
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("CargoBuild", function(opts)
    local args = opts.args ~= "" and opts.args or ""
    U.terminal_raw("cargo build " .. args)
end, { nargs = "?", desc = "cargo build" })

vim.api.nvim_create_user_command("CargoBuildRelease", function()
    U.terminal_raw("cargo build --release")
end, { desc = "cargo build --release" })

vim.api.nvim_create_user_command("CargoRun", function(opts)
    local args = opts.args ~= "" and " -- " .. opts.args or ""
    U.terminal_raw("cargo run" .. args)
end, { nargs = "?", desc = "cargo run" })

vim.api.nvim_create_user_command("CargoRunRelease", function(opts)
    local args = opts.args ~= "" and " -- " .. opts.args or ""
    U.terminal_raw("cargo run --release" .. args)
end, { nargs = "?", desc = "cargo run --release" })

-- ════════════════════════════════════════════════════════════════════════════
-- Testing
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("CargoTest", function(opts)
    local args = opts.args ~= "" and opts.args or ""
    U.terminal_raw("cargo test " .. args)
end, { nargs = "?", desc = "cargo test" })

vim.api.nvim_create_user_command("CargoTestFunc", function()
    local func_name = nil
    local node = vim.treesitter.get_node()
    while node do
        if node:type() == "function_item" then
            local name_node = node:field("name")[1]
            if name_node then
                func_name = vim.treesitter.get_node_text(name_node, 0)
                break
            end
        end
        node = node:parent()
    end

    if not func_name then
        U.notify("Cursor not in a function", vim.log.levels.WARN)
        return
    end

    U.terminal_raw(string.format("cargo test %s -- --exact --nocapture", func_name))
end, { desc = "Test function under cursor" })

-- ════════════════════════════════════════════════════════════════════════════
-- Code Quality
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("CargoCheck", function()
    U.notify("Running: cargo check")
    U.run_cmd({ "cargo", "check", "--message-format=short" }, {
        cwd = cargo_root(),
        on_exit = function(result)
            if result.code == 0 then
                U.notify("cargo check: OK")
            else
                U.notify("cargo check failed:\n" .. (result.stderr or result.stdout), vim.log.levels.WARN)
            end
        end,
    })
end, { desc = "cargo check" })

vim.api.nvim_create_user_command("CargoClippy", function(opts)
    local args = opts.args ~= "" and opts.args or ""
    U.terminal_raw("cargo clippy " .. args)
end, { nargs = "?", desc = "cargo clippy" })

vim.api.nvim_create_user_command("CargoFmt", function()
    U.notify("Running: cargo fmt")
    U.run_cmd({ "cargo", "fmt" }, {
        cwd = cargo_root(),
        on_exit = function(result)
            if result.code == 0 then
                vim.cmd("checktime")
                U.notify("cargo fmt: completed")
            else
                U.notify("cargo fmt failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { desc = "cargo fmt" })

vim.api.nvim_create_user_command("CargoFmtCheck", function()
    U.notify("Running: cargo fmt --check")
    U.run_cmd({ "cargo", "fmt", "--check" }, {
        cwd = cargo_root(),
        on_exit = function(result)
            if result.code == 0 then
                U.notify("cargo fmt --check: OK")
            else
                U.notify("cargo fmt --check: formatting needed\n" .. (result.stdout or ""), vim.log.levels.WARN)
            end
        end,
    })
end, { desc = "cargo fmt --check" })

-- ════════════════════════════════════════════════════════════════════════════
-- Dependencies
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("CargoAdd", function(opts)
    if opts.args == "" then
        U.notify("Usage: CargoAdd <crate>", vim.log.levels.WARN)
        return
    end
    U.notify("Running: cargo add " .. opts.args)
    U.run_cmd({ "cargo", "add", unpack(vim.split(opts.args, " ")) }, {
        cwd = cargo_root(),
        on_exit = function(result)
            if result.code == 0 then
                U.notify("Added: " .. opts.args)
                vim.cmd("checktime")
            else
                U.notify("cargo add failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { nargs = "+", desc = "cargo add <crate>" })

vim.api.nvim_create_user_command("CargoRemove", function(opts)
    if opts.args == "" then
        U.notify("Usage: CargoRemove <crate>", vim.log.levels.WARN)
        return
    end
    U.notify("Running: cargo remove " .. opts.args)
    U.run_cmd({ "cargo", "remove", opts.args }, {
        cwd = cargo_root(),
        on_exit = function(result)
            if result.code == 0 then
                U.notify("Removed: " .. opts.args)
                vim.cmd("checktime")
            else
                U.notify("cargo remove failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { nargs = 1, desc = "cargo remove <crate>" })

vim.api.nvim_create_user_command("CargoUpdate", function()
    U.notify("Running: cargo update")
    U.run_cmd({ "cargo", "update" }, {
        cwd = cargo_root(),
        on_exit = function(result)
            if result.code == 0 then
                U.notify("cargo update: completed")
                vim.cmd("checktime")
            else
                U.notify("cargo update failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { desc = "cargo update" })

vim.api.nvim_create_user_command("CargoTree", function(opts)
    local args = opts.args ~= "" and opts.args or ""
    U.terminal_raw("cargo tree " .. args)
end, { nargs = "?", desc = "cargo tree" })

-- ════════════════════════════════════════════════════════════════════════════
-- Documentation
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("CargoDoc", function(opts)
    if opts.bang then
        U.notify("Running: cargo doc --open")
        U.run_cmd({ "cargo", "doc", "--open" }, {
            cwd = cargo_root(),
            on_exit = function(result)
                if result.code == 0 then
                    U.notify("cargo doc: completed")
                else
                    U.notify("cargo doc failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
                end
            end,
        })
    else
        U.notify("Running: cargo doc")
        U.run_cmd({ "cargo", "doc" }, {
            cwd = cargo_root(),
            on_exit = function(result)
                if result.code == 0 then
                    U.notify("cargo doc: completed")
                else
                    U.notify("cargo doc failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
                end
            end,
        })
    end
end, { bang = true, desc = "cargo doc (! to open)" })

vim.api.nvim_create_user_command("RustDoc", function(opts)
    local crate = opts.args ~= "" and opts.args or vim.fn.expand("<cword>")
    local url = "https://docs.rs/" .. crate
    local open_cmd = vim.fn.has("mac") == 1 and "open" or "xdg-open"
    vim.fn.system({ open_cmd, url })
    U.notify("Opening: " .. url)
end, { nargs = "?", desc = "Open docs.rs for crate" })

-- ════════════════════════════════════════════════════════════════════════════
-- Project Management
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("CargoNew", function(opts)
    if opts.args == "" then
        U.notify("Usage: CargoNew <name> [--lib]", vim.log.levels.WARN)
        return
    end
    U.notify("Running: cargo new " .. opts.args)
    U.run_cmd({ "cargo", "new", unpack(vim.split(opts.args, " ")) }, {
        on_exit = function(result)
            if result.code == 0 then
                U.notify("Created: " .. opts.args)
            else
                U.notify("cargo new failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { nargs = "+", desc = "cargo new <name>" })

vim.api.nvim_create_user_command("CargoInit", function(opts)
    local args = opts.args ~= "" and opts.args or ""
    U.notify("Running: cargo init " .. args)
    local cmd = args ~= "" and { "cargo", "init", unpack(vim.split(args, " ")) } or { "cargo", "init" }
    U.run_cmd(cmd, {
        on_exit = function(result)
            if result.code == 0 then
                U.notify("cargo init: completed")
                vim.cmd("checktime")
            else
                U.notify("cargo init failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { nargs = "?", desc = "cargo init" })

vim.api.nvim_create_user_command("CargoClean", function()
    U.notify("Running: cargo clean")
    U.run_cmd({ "cargo", "clean" }, {
        cwd = cargo_root(),
        on_exit = function(result)
            if result.code == 0 then
                U.notify("cargo clean: completed")
            else
                U.notify("cargo clean failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { desc = "cargo clean" })

-- ════════════════════════════════════════════════════════════════════════════
-- Utilities
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("CargoExpand", function(opts)
    local args = opts.args ~= "" and opts.args or ""
    U.terminal_raw("cargo expand " .. args)
end, { nargs = "?", desc = "cargo expand (macro expansion)" })

vim.api.nvim_create_user_command("CargoAudit", function()
    U.terminal_raw("cargo audit")
end, { desc = "cargo audit (security vulnerabilities)" })

vim.api.nvim_create_user_command("CargoOutdated", function()
    U.terminal_raw("cargo outdated")
end, { desc = "cargo outdated" })

vim.api.nvim_create_user_command("CargoBench", function(opts)
    local args = opts.args ~= "" and opts.args or ""
    U.terminal_raw("cargo bench " .. args)
end, { nargs = "?", desc = "cargo bench" })

-- ════════════════════════════════════════════════════════════════════════════
-- Navigation
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("RustAlt", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    local dir = vim.fn.fnamemodify(filepath, ":h")
    local root = cargo_root()

    -- Determine src/ path
    local rel = filepath:sub(#root + 2) -- strip root + "/"
    local in_src = rel:match("^src/")

    if rel:match("^tests/") then
        -- In integration test -> go to corresponding src/ file
        local name = vim.fn.fnamemodify(rel, ":t:r")
        local target = root .. "/src/" .. name .. ".rs"
        if vim.fn.filereadable(target) == 1 then
            vim.cmd("edit " .. target)
        else
            U.notify("Source file not found: " .. target, vim.log.levels.WARN)
        end
    elseif in_src then
        -- In src/ file -> find tests/{name}.rs
        local name = vim.fn.fnamemodify(rel, ":t:r")
        local test_file = root .. "/tests/" .. name .. ".rs"
        if vim.fn.filereadable(test_file) == 1 then
            vim.cmd("edit " .. test_file)
        else
            U.notify("Test file not found: " .. test_file, vim.log.levels.INFO)
        end
    else
        U.notify("RustAlt works from src/ or tests/ directories", vim.log.levels.INFO)
    end
end, { desc = "Switch between src and tests" })

vim.api.nvim_create_user_command("RustAltV", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    local root = cargo_root()
    local rel = filepath:sub(#root + 2)

    if rel:match("^tests/") then
        local name = vim.fn.fnamemodify(rel, ":t:r")
        local target = root .. "/src/" .. name .. ".rs"
        if vim.fn.filereadable(target) == 1 then
            vim.cmd("vsplit " .. target)
        else
            U.notify("Source file not found: " .. target, vim.log.levels.WARN)
        end
    elseif rel:match("^src/") then
        local name = vim.fn.fnamemodify(rel, ":t:r")
        local test_file = root .. "/tests/" .. name .. ".rs"
        if vim.fn.filereadable(test_file) == 1 then
            vim.cmd("vsplit " .. test_file)
        else
            U.notify("Test file not found: " .. test_file, vim.log.levels.INFO)
        end
    else
        U.notify("RustAltV works from src/ or tests/ directories", vim.log.levels.INFO)
    end
end, { desc = "Switch between src and tests (vsplit)" })

-- ════════════════════════════════════════════════════════════════════════════
-- Cargo Subcommand Installation
-- ════════════════════════════════════════════════════════════════════════════

local cargo_tools = {
    { name = "cargo-expand", desc = "Macro expansion" },
    { name = "cargo-audit", desc = "Security audit" },
    { name = "cargo-outdated", desc = "Check outdated deps" },
    { name = "cargo-edit", desc = "Add/remove/upgrade deps" },
    { name = "cargo-watch", desc = "Watch for changes" },
    { name = "cargo-nextest", desc = "Better test runner" },
    { name = "cargo-flamegraph", desc = "Flamegraph profiling" },
}

local function install_cargo_tools_async(tools, index, on_complete)
    index = index or 1
    if index > #tools then
        on_complete()
        return
    end
    local tool = tools[index]
    U.notify(string.format("[%d/%d] Installing: %s", index, #tools, tool.name))
    U.run_cmd({ "cargo", "install", tool.name }, {
        on_exit = function(result)
            if result.code ~= 0 then
                U.notify(string.format("Failed to install %s: %s", tool.name, result.stderr or ""), vim.log.levels.ERROR)
            end
            install_cargo_tools_async(tools, index + 1, on_complete)
        end,
    })
end

vim.api.nvim_create_user_command("CargoInstallTools", function()
    U.notify("Installing Cargo tools (this may take a few minutes)...")
    install_cargo_tools_async(cargo_tools, 1, function()
        U.notify("All Cargo tools installed!")
    end)
end, { desc = "Install useful cargo subcommands" })

vim.api.nvim_create_user_command("CargoInstallTool", function(opts)
    if opts.args == "" then
        local tool_list = {}
        for _, t in ipairs(cargo_tools) do
            table.insert(tool_list, string.format("  %s - %s", t.name, t.desc))
        end
        U.notify("Available tools:\n" .. table.concat(tool_list, "\n"))
        return
    end
    U.notify("Installing: " .. opts.args .. "...")
    U.run_cmd({ "cargo", "install", opts.args }, {
        on_exit = function(result)
            if result.code == 0 then
                U.notify("Installed: " .. opts.args)
            else
                U.notify("Failed to install " .. opts.args .. ": " .. (result.stderr or ""), vim.log.levels.ERROR)
            end
        end,
    })
end, {
    nargs = "?",
    complete = function()
        return vim.tbl_map(function(t) return t.name end, cargo_tools)
    end,
    desc = "Install a specific cargo tool",
})

-- ════════════════════════════════════════════════════════════════════════════
-- Suggested keymaps (uncomment and adjust to taste)
-- ════════════════════════════════════════════════════════════════════════════
-- vim.keymap.set("n", "<leader>rb", "<cmd>CargoBuild<cr>", { desc = "Cargo Build" })
-- vim.keymap.set("n", "<leader>rr", "<cmd>CargoRun<cr>", { desc = "Cargo Run" })
-- vim.keymap.set("n", "<leader>rt", "<cmd>CargoTest<cr>", { desc = "Cargo Test" })
-- vim.keymap.set("n", "<leader>rtf", "<cmd>CargoTestFunc<cr>", { desc = "Cargo Test Func" })
-- vim.keymap.set("n", "<leader>rk", "<cmd>CargoCheck<cr>", { desc = "Cargo Check" })
-- vim.keymap.set("n", "<leader>rc", "<cmd>CargoClippy<cr>", { desc = "Cargo Clippy" })
-- vim.keymap.set("n", "<leader>rf", "<cmd>CargoFmt<cr>", { desc = "Cargo Fmt" })
-- vim.keymap.set("n", "<leader>ra", "<cmd>RustAlt<cr>", { desc = "Rust Alt File" })
-- vim.keymap.set("n", "<leader>rav", "<cmd>RustAltV<cr>", { desc = "Rust Alt File (vsplit)" })
