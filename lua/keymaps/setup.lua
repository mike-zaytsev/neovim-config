local files = { "autoformat", "cmake", "debug", "menu", "navigation", "toggle" }

for _, filename in ipairs(files) do
    for _, mapping in ipairs(require("keymaps." .. filename)) do
        if mapping.mode == nil then
            mapping.mode = "n"
        end
        if mapping.opts == nil then
            mapping.opts = {}
        end
        vim.keymap.set(mapping.mode, mapping.keys, mapping.command, mapping.opts)
    end
end
