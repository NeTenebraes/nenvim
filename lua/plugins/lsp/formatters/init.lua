-- ============================================================================
-- MÓDULO: lua/plugins/lsp/formatters/init.lua
-- PROPÓSITO: Loader dinámico, orquestador de Conform.nvim y registro de :FormatInit
-- COMPATIBILIDAD: Neovim 0.10+ / 0.12 (Usa vim.fs.root nativo)
-- ============================================================================

-- 1. CARGA SEGURA DE DEPENDENCIAS
local ok_conform, conform = pcall(require, "conform")
if not ok_conform then
    return
end

-- 2. REGISTRO DE SUBMÓDULOS DE FORMATEO
local modules = {
    "plugins.lsp.formatters.javascript",
    "plugins.lsp.formatters.markdown",
    "plugins.lsp.formatters.lua",
    "plugins.lsp.formatters.shell",
    "plugins.lsp.formatters.generic",
}

-- 3. ESTRUCTURAS DE DATOS (ESTADO)
local combined_formatters_by_ft = {}
local combined_formatters = {}
local init_configs = {}

-- 4. FUSIÓN DINÁMICA DE CONFIGURACIONES
for _, mod_path in ipairs(modules) do
    local ok, mod = pcall(require, mod_path)
    if ok and type(mod) == "table" then
        -- Mapeo de filetype -> formateadores
        if mod.formatters_by_ft then
            combined_formatters_by_ft = vim.tbl_deep_extend("force", combined_formatters_by_ft, mod.formatters_by_ft)
        end

        -- Anulación / personalización de parámetros de CLI
        if mod.formatters then
            combined_formatters = vim.tbl_deep_extend("force", combined_formatters, mod.formatters)
        end

        -- Registro de plantillas para :FormatInit
        if mod.init_config and mod.formatters_by_ft then
            for ft, _ in pairs(mod.formatters_by_ft) do
                init_configs[ft] = mod.init_config
            end
        end
    end
end

-- 5. INICIALIZACIÓN Y CONFIGURACIÓN DE CONFORM.NVIM
conform.setup({
    formatters_by_ft = combined_formatters_by_ft,
    formatters = combined_formatters,
    format_on_save = {
        timeout_ms = 2000,
        lsp_format = "fallback",
    },
})

-- 6. REGISTRO DEL COMANDO DE USUARIO (:FormatInit)
vim.api.nvim_create_user_command("FormatInit", function(opts)
    local ft = (opts.args ~= "") and opts.args or vim.bo.filetype
    local config = init_configs[ft]

    if not config then
        vim.notify("[FormatInit] No hay plantilla registrada para: " .. tostring(ft), vim.log.levels.WARN)
        return
    end

    -- Detección de la raíz del proyecto usando el motor de Nvim 0.10+
    local root = vim.fs.root(0, { "package.json", ".git", "Makefile", ".stylua.toml" }) or vim.fn.getcwd()
    local target_path = root .. "/" .. config.filename

    if vim.fn.filereadable(target_path) == 1 then
        vim.notify("[FormatInit] El archivo '" .. config.filename .. "' ya existe.", vim.log.levels.WARN)
        return
    end

    local file = io.open(target_path, "w")
    if file then
        file:write(config.content)
        file:close()
        vim.notify("[FormatInit] Creado exitosamente: " .. config.filename, vim.log.levels.INFO)
    else
        vim.notify("[FormatInit] Error al escribir en: " .. target_path, vim.log.levels.ERROR)
    end
end, {
    desc = "Genera el archivo de configuración del formateador para el filetype actual/especificado",
    nargs = "?",
    complete = function()
        local keys = {}
        for k in pairs(init_configs) do
            table.insert(keys, k)
        end
        table.sort(keys)
        return keys
    end,
})
