return {
    "Civitasv/cmake-tools.nvim",
    opts = {
        cmake_command = "cmake",
        cmake_regenerate_on_save = true,
        cmake_generate_options = {
            "-DCMAKE_EXPORT_COMPILE_COMMANDS=1",
            "-DCMAKE_INSTALL_PREFIX=./install",
            "-DFETCHCONTENT_QUIET=OFF",
            "-GNinja",
        },
        cmake_build_directory = "build/${variant:buildType}",
        cmake_dap_configuration = {
            name = "cpp",
            type = "lldb",
            request = "launch",
            runInTerminal = true,
        },
    },
}
