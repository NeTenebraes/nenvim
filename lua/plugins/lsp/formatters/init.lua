-- =========================================================
-- lua/plugins/lsp/formatters/init.lua
-- Loader dinamico y orquestador de Conform.nvim
-- =========================================================

local ok_conform, conform = pcall(require, "conform")
if not ok_conform then
    return
end

-- Lista de submódulos a cargar
local modules = {
    "plugins.lsp.formatters.javascript",
    "plugins.lsp.formatters.markdown",
    "plugins.lsp.formatters.lua",
    "plugins.lsp.formatters.shell",
    "plugins.lsp.formatters.generic",
}

-- Estructuras finales que recibirá Conform
local combined_formatters_by_ft = {}
local combined_formatters = {}

-- Fusionamos las configuraciones de cada archivo
for _, mod_path in ipairs(modules) do
    local ok, mod = pcall(require, mod_path)
    if ok and type(mod) == "table" then
        -- Unir formatters_by_ft
        if mod.formatters_by_ft then
            combined_formatters_by_ft = vim.tbl_deep_extend("force", combined_formatters_by_ft, mod.formatters_by_ft)
        end
        -- Unir reglas custom de formatters
        if mod.formatters then
            combined_formatters = vim.tbl_deep_extend("force", combined_formatters, mod.formatters)
        end
    end
end

-- Inicialización de Conform con la tabla combinada
conform.setup({
    formatters_by_ft = combined_formatters_by_ft,
    formatters = combined_formatters,

    format_on_save = {
        timeout_ms = 2000,
        lsp_format = "fallback",
    },
})
