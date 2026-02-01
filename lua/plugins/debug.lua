return {
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")

            dap.adapters.lldb = {
                type = "executable",
                command = "/usr/bin/lldb-dap",
                name = "lldb",
            }

            dap.adapters.gdb = {
                type = "executable",
                command = "gdb",
                args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
            }

            local check_executable = function(filepath, type)
                local stat_results = vim.system({ "stat", "--format", "%A", filepath }):wait()
                return string.find(stat_results.stdout, "x") and type == "file"
            end

            local args = {}
            vim.api.nvim_create_user_command("SetDebugLaunchArgs", function()
                vim.ui.input({ prompt = "Enter debuggee launch arguments: " }, function(inp)
                    args = {}
                    for arg in inp:gmatch("%S+") do
                        table.insert(args, arg)
                    end
                end)
            end, {})

            local cpp_config = {}
            setmetatable(cpp_config, {
                __call = function()
                    local file_selector = require("custom.select-file").select_file
                    local executable = file_selector(check_executable)
                    if executable == nil then
                        return { program = dap.ABORT }
                    end

                    local settings = {
                        name = "LLDB launch file",
                        type = "lldb",
                        request = "launch",
                        program = executable,
                        cwd = "${workspaceFolder}",
                        args = args,
                        runInTerminal = true,
                        stopOnEntry = false,
                    }

                    return settings
                end,
            })

            dap.configurations.cpp = {
                cpp_config,
            }
            dap.configurations.c = {
                cpp_config,
            }
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup()

            local open_ui = function()
                dapui.open()
            end
            local close_ui = function()
                dapui.close()
            end

            dap.listeners.before["attach"]["dapui-config"] = open_ui
            dap.listeners.before["launch"]["dapui-config"] = open_ui
            dap.listeners.after["event_exited"]["dapui-config"] = close_ui
            dap.listeners.after["event_terminated"]["dapui-config"] = close_ui
        end,
    },
}
