-- ════════════════════════════════════════════════════════════════════════════
-- Go Tools - Custom commands for Go development
-- ════════════════════════════════════════════════════════════════════════════

local U = require("cool_stuff.utils")

local function go_root()
    return U.get_project_root("go.mod")
end

-- ════════════════════════════════════════════════════════════════════════════
-- Build & Run
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("GoBuild", function(opts)
    local args = opts.args ~= "" and opts.args or "./..."
    U.notify("Building: go build " .. args)
    U.run_cmd({ "go", "build", args }, {
        cwd = go_root(),
        on_exit = function(result)
            if result.code == 0 then
                U.notify("Build successful")
            else
                U.notify("Build failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { nargs = "?", desc = "go build" })

vim.api.nvim_create_user_command("GoRun", function(opts)
    local args = opts.args ~= "" and opts.args or "."
    U.terminal_raw("go run " .. args)
end, { nargs = "?", desc = "go run" })

vim.api.nvim_create_user_command("GoGenerate", function(opts)
    local args = opts.args ~= "" and opts.args or "./..."
    U.notify("Running: go generate " .. args)
    U.run_cmd({ "go", "generate", args }, {
        cwd = go_root(),
        on_exit = function(result)
            if result.code == 0 then
                U.notify("Generate completed")
                vim.cmd("checktime")
            else
                U.notify("Generate failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { nargs = "?", desc = "go generate" })

-- ════════════════════════════════════════════════════════════════════════════
-- Testing
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("GoTest", function(opts)
    local args = opts.args ~= "" and opts.args or "./..."
    U.terminal_raw("go test -v " .. args)
end, { nargs = "?", desc = "go test" })

vim.api.nvim_create_user_command("GoTestFunc", function()
    local func_name = nil
    local node = vim.treesitter.get_node()
    while node do
        if node:type() == "function_declaration" then
            local name_node = node:field("name")[1]
            if name_node then
                func_name = vim.treesitter.get_node_text(name_node, 0)
                break
            end
        end
        node = node:parent()
    end

    if not func_name or not func_name:match("^Test") then
        U.notify("Cursor not in a Test function", vim.log.levels.WARN)
        return
    end

    local pkg = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
    U.terminal_raw(string.format("go test -v -run ^%s$ %s", func_name, pkg))
end, { desc = "Test function under cursor" })

vim.api.nvim_create_user_command("GoTestFile", function()
    local pkg = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
    U.terminal_raw("go test -v " .. pkg)
end, { desc = "Test current package" })

vim.api.nvim_create_user_command("GoCoverage", function(opts)
    local args = opts.args ~= "" and opts.args or "./..."
    U.terminal_raw("go test -coverprofile=coverage.out " .. args .. " && go tool cover -html=coverage.out")
end, { nargs = "?", desc = "go test with coverage" })

-- ════════════════════════════════════════════════════════════════════════════
-- Module Management
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("GoModTidy", function()
    U.notify("Running: go mod tidy")
    U.run_cmd({ "go", "mod", "tidy" }, {
        cwd = go_root(),
        on_exit = function(result)
            if result.code == 0 then
                U.notify("go mod tidy completed")
                vim.cmd("checktime")
            else
                U.notify("go mod tidy failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { desc = "go mod tidy" })

vim.api.nvim_create_user_command("GoModInit", function(opts)
    if opts.args == "" then
        U.notify("Usage: GoModInit <module-name>", vim.log.levels.WARN)
        return
    end
    U.notify("Running: go mod init " .. opts.args)
    U.run_cmd({ "go", "mod", "init", opts.args }, {
        on_exit = function(result)
            if result.code == 0 then
                U.notify("go mod init completed")
                vim.cmd("checktime")
            else
                U.notify("go mod init failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { nargs = 1, desc = "go mod init <module>" })

vim.api.nvim_create_user_command("GoGet", function(opts)
    if opts.args == "" then
        U.notify("Usage: GoGet <package>", vim.log.levels.WARN)
        return
    end
    U.notify("Running: go get " .. opts.args)
    U.run_cmd({ "go", "get", opts.args }, {
        cwd = go_root(),
        on_exit = function(result)
            if result.code == 0 then
                U.notify("go get completed")
                vim.cmd("checktime")
            else
                U.notify("go get failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { nargs = 1, desc = "go get <package>" })

-- ════════════════════════════════════════════════════════════════════════════
-- Code Tools
-- ════════════════════════════════════════════════════════════════════════════

vim.api.nvim_create_user_command("GoVet", function(opts)
    local args = opts.args ~= "" and opts.args or "./..."
    U.notify("Running: go vet " .. args)
    U.run_cmd({ "go", "vet", args }, {
        cwd = go_root(),
        on_exit = function(result)
            if result.code == 0 then
                U.notify("go vet: no issues found")
            else
                U.notify("go vet:\n" .. (result.stderr or result.stdout), vim.log.levels.WARN)
            end
        end,
    })
end, { nargs = "?", desc = "go vet" })

vim.api.nvim_create_user_command("GoLint", function(opts)
    local args = opts.args ~= "" and opts.args or "./..."
    U.notify("Running: golangci-lint run " .. args)
    U.run_cmd({ "golangci-lint", "run", args }, {
        cwd = go_root(),
        on_exit = function(result)
            if result.code == 0 then
                U.notify("golangci-lint: no issues found")
            else
                U.notify("golangci-lint:\n" .. (result.stdout or result.stderr), vim.log.levels.WARN)
            end
        end,
    })
end, { nargs = "?", desc = "golangci-lint run" })

vim.api.nvim_create_user_command("GoDoc", function(opts)
    local target = opts.args ~= "" and opts.args or vim.fn.expand("<cword>")
    if target == "" then
        U.notify("Usage: GoDoc <symbol>", vim.log.levels.WARN)
        return
    end
    U.terminal({ "go", "doc", target })
end, { nargs = "?", desc = "go doc <symbol>" })

-- GoImpl: generate interface implementation stubs (async)
vim.api.nvim_create_user_command("GoImpl", function(opts)
    if opts.args == "" then
        U.notify("Usage: GoImpl <recv> <interface> (e.g., GoImpl 's *Service' io.Reader)", vim.log.levels.WARN)
        return
    end
    local impl = vim.fn.exepath("impl")
    if impl == "" then
        U.notify("impl not found. Install with: go install github.com/josharian/impl@latest", vim.log.levels.ERROR)
        return
    end
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local bufnr = vim.api.nvim_get_current_buf()
    U.run_cmd({ "impl", unpack(vim.split(opts.args, " ")) }, {
        on_exit = function(result)
            if result.code == 0 then
                local lines = vim.split(vim.trim(result.stdout), "\n")
                vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)
                U.notify("Implementation inserted")
            else
                U.notify("impl failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { nargs = "+", desc = "Generate interface implementation" })

-- GoIfErr: insert if err != nil block (async)
vim.api.nvim_create_user_command("GoIfErr", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local iferr = vim.fn.exepath("iferr")
    if iferr == "" then
        vim.api.nvim_buf_set_lines(bufnr, row, row, false, { "if err != nil {", "\treturn err", "}" })
        return
    end
    local pos = vim.fn.getcurpos()
    local byte_offset = vim.fn.line2byte(pos[2]) + pos[3] - 1
    U.run_cmd({ "iferr", "-pos", tostring(byte_offset) }, {
        on_exit = function(result)
            if result.code == 0 and result.stdout ~= "" then
                local lines = vim.split(vim.trim(result.stdout), "\n")
                vim.api.nvim_buf_set_lines(bufnr, pos[2], pos[2], false, lines)
            else
                vim.api.nvim_buf_set_lines(bufnr, row, row, false, { "if err != nil {", "\treturn err", "}" })
            end
        end,
    })
end, { desc = "Insert if err != nil block" })

-- GoModernize: runs gopls modernize analyzer (async)
vim.api.nvim_create_user_command("GoModernize", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath == "" then
        U.notify("Buffer has no file path", vim.log.levels.ERROR)
        return
    end
    vim.cmd("silent write")
    U.notify("GoModernize: running...")
    U.run_cmd({
        "go", "run",
        "golang.org/x/tools/gopls/internal/analysis/modernize/cmd/modernize@latest",
        "-fix", filepath,
    }, {
        on_exit = function(result)
            if result.code == 0 then
                vim.cmd("checktime")
                U.notify("GoModernize: completed")
            else
                U.notify("GoModernize failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { desc = "Run gopls modernize -fix on current buffer" })

-- GoFillStruct: fill struct with default values
vim.api.nvim_create_user_command("GoFillStruct", function()
    vim.lsp.buf.code_action({
        filter = function(action)
            return action.title:match("Fill") ~= nil
        end,
        apply = true,
    })
end, { desc = "Fill struct with default values" })

-- GoAddTags: add struct tags (async, requires gomodifytags)
vim.api.nvim_create_user_command("GoAddTags", function(opts)
    local tags = opts.args ~= "" and opts.args or "json"
    local gomodifytags = vim.fn.exepath("gomodifytags")
    if gomodifytags == "" then
        U.notify("gomodifytags not found. Install with: go install github.com/fatih/gomodifytags@latest", vim.log.levels.ERROR)
        return
    end
    local filepath = vim.api.nvim_buf_get_name(0)
    local line = vim.fn.line(".")
    vim.cmd("silent write")
    U.run_cmd({ "gomodifytags", "-file", filepath, "-line", tostring(line), "-add-tags", tags }, {
        on_exit = function(result)
            if result.code == 0 then
                vim.cmd("edit!")
                U.notify("Tags added: " .. tags)
            else
                U.notify("GoAddTags failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { nargs = "?", desc = "Add struct tags (default: json)" })

-- GoRemoveTags: remove struct tags (async)
vim.api.nvim_create_user_command("GoRemoveTags", function(opts)
    local tags = opts.args ~= "" and opts.args or "json"
    if vim.fn.exepath("gomodifytags") == "" then
        U.notify("gomodifytags not found", vim.log.levels.ERROR)
        return
    end
    local filepath = vim.api.nvim_buf_get_name(0)
    local line = vim.fn.line(".")
    vim.cmd("silent write")
    U.run_cmd({ "gomodifytags", "-file", filepath, "-line", tostring(line), "-remove-tags", tags }, {
        on_exit = function(result)
            if result.code == 0 then
                vim.cmd("edit!")
                U.notify("Tags removed: " .. tags)
            else
                U.notify("GoRemoveTags failed:\n" .. (result.stderr or result.stdout), vim.log.levels.ERROR)
            end
        end,
    })
end, { nargs = "?", desc = "Remove struct tags (default: json)" })

-- GoAlt: switch between test and source file
vim.api.nvim_create_user_command("GoAlt", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    local alt
    if filepath:match("_test%.go$") then
        alt = filepath:gsub("_test%.go$", ".go")
    else
        alt = filepath:gsub("%.go$", "_test.go")
    end
    if vim.fn.filereadable(alt) == 1 then
        vim.cmd("edit " .. alt)
    else
        U.notify("Alt file not found: " .. alt, vim.log.levels.WARN)
    end
end, { desc = "Switch between test and source file" })

vim.api.nvim_create_user_command("GoAltV", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    local alt
    if filepath:match("_test%.go$") then
        alt = filepath:gsub("_test%.go$", ".go")
    else
        alt = filepath:gsub("%.go$", "_test.go")
    end
    if vim.fn.filereadable(alt) == 1 then
        vim.cmd("vsplit " .. alt)
    else
        U.notify("Alt file not found: " .. alt, vim.log.levels.WARN)
    end
end, { desc = "Switch to alt file in vsplit" })

-- ════════════════════════════════════════════════════════════════════════════
-- Binary Installation
-- ════════════════════════════════════════════════════════════════════════════

local go_tools = {
    { name = "goimports", url = "golang.org/x/tools/cmd/goimports@latest" },
    { name = "gomodifytags", url = "github.com/fatih/gomodifytags@latest" },
    { name = "impl", url = "github.com/josharian/impl@latest" },
    { name = "iferr", url = "github.com/koron/iferr@latest" },
    { name = "gotests", url = "github.com/cweill/gotests/gotests@latest" },
    { name = "golangci-lint", url = "github.com/golangci/golangci-lint/cmd/golangci-lint@latest" },
    { name = "dlv", url = "github.com/go-delve/delve/cmd/dlv@latest" },
    { name = "staticcheck", url = "honnef.co/go/tools/cmd/staticcheck@latest" },
    { name = "govulncheck", url = "golang.org/x/vuln/cmd/govulncheck@latest" },
}

local function install_tools_async(tools, index, action, on_complete)
    index = index or 1
    if index > #tools then
        on_complete()
        return
    end
    local tool = tools[index]
    U.notify(string.format("[%d/%d] %s: %s", index, #tools, action, tool.name))
    U.run_cmd({ "go", "install", tool.url }, {
        on_exit = function(result)
            if result.code ~= 0 then
                U.notify(string.format("Failed to install %s: %s", tool.name, result.stderr or ""), vim.log.levels.ERROR)
            end
            install_tools_async(tools, index + 1, action, on_complete)
        end,
    })
end

vim.api.nvim_create_user_command("GoInstallBinaries", function()
    U.notify("Installing Go binaries (this may take a minute)...")
    install_tools_async(go_tools, 1, "Installing", function()
        U.notify("All Go binaries installed!")
    end)
end, { desc = "Install all Go tool binaries" })

vim.api.nvim_create_user_command("GoUpdateBinaries", function()
    U.notify("Updating Go binaries (this may take a minute)...")
    install_tools_async(go_tools, 1, "Updating", function()
        U.notify("All Go binaries updated!")
    end)
end, { desc = "Update all Go tool binaries" })

vim.api.nvim_create_user_command("GoInstallBinary", function(opts)
    if opts.args == "" then
        local names = vim.tbl_map(function(t) return t.name end, go_tools)
        U.notify("Available tools: " .. table.concat(names, ", "))
        return
    end
    for _, tool in ipairs(go_tools) do
        if tool.name == opts.args then
            U.notify("Installing: " .. tool.name .. "...")
            U.run_cmd({ "go", "install", tool.url }, {
                on_exit = function(result)
                    if result.code == 0 then
                        U.notify("Installed: " .. tool.name)
                    else
                        U.notify("Failed to install " .. tool.name .. ": " .. (result.stderr or ""), vim.log.levels.ERROR)
                    end
                end,
            })
            return
        end
    end
    U.notify("Unknown tool: " .. opts.args, vim.log.levels.WARN)
end, {
    nargs = "?",
    complete = function()
        return vim.tbl_map(function(t) return t.name end, go_tools)
    end,
    desc = "Install a specific Go tool binary",
})

-- ════════════════════════════════════════════════════════════════════════════
-- Suggested keymaps (uncomment and adjust to taste)
-- ════════════════════════════════════════════════════════════════════════════
-- vim.keymap.set("n", "<leader>gb", "<cmd>GoBuild<cr>", { desc = "Go Build" })
-- vim.keymap.set("n", "<leader>gr", "<cmd>GoRun<cr>", { desc = "Go Run" })
-- vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<cr>", { desc = "Go Test" })
-- vim.keymap.set("n", "<leader>gtf", "<cmd>GoTestFunc<cr>", { desc = "Go Test Func" })
-- vim.keymap.set("n", "<leader>ga", "<cmd>GoAlt<cr>", { desc = "Go Alt File" })
-- vim.keymap.set("n", "<leader>gav", "<cmd>GoAltV<cr>", { desc = "Go Alt File (vsplit)" })
-- vim.keymap.set("n", "<leader>gc", "<cmd>GoCoverage<cr>", { desc = "Go Coverage" })
-- vim.keymap.set("n", "<leader>gv", "<cmd>GoVet<cr>", { desc = "Go Vet" })
-- vim.keymap.set("n", "<leader>gl", "<cmd>GoLint<cr>", { desc = "Go Lint" })
-- vim.keymap.set("n", "<leader>gfs", "<cmd>GoFillStruct<cr>", { desc = "Go Fill Struct" })
-- vim.keymap.set("n", "<leader>gie", "<cmd>GoIfErr<cr>", { desc = "Go If Err" })
