-- ============================================================================
-- MÓDULO: lua/plugins/lsp/formatters/javascript.lua
-- PROPÓSITO: Configuración de Prettier para JS/TS y Ecosistema Web.
--
-- COMPORTAMIENTO:
--   - Busca un binario local en node_modules/.bin/prettier antes de usar el global.
--   - Si el proyecto contiene un archivo .prettierrc*, respeta dicha config.
--   - Si NO existe config local, aplica el fallback usando las reglas definidas en `defaults`.
--   - Construye dinámicamente tanto las banderas de CLI como el JSON para :FormatInit.
--
-- HERRAMIENTAS REQUERIDAS:
--   - Prettier (vía npm, Mason o paquete del sistema)
--
-- COMPATIBILIDAD: Neovim 0.10+ (Usa vim.fs.root nativo)
-- ============================================================================

-- 1. CONFIG
local defaults = {
    tabWidth = 4,
    useTabs = false,
    semi = true,
    singleQuote = false,
    trailingComma = "es5",
}

-- Archivos de configuración de Prettier reconocidos habitualmente
local prettier_configs = {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yml",
    ".prettierrc.yaml",
    ".prettierrc.json5",
    ".prettierrc.js",
    ".prettierrc.cjs",
    ".prettierrc.mjs",
    "prettier.config.js",
    "prettier.config.cjs",
    "prettier.config.mjs",
}

local function has_local_prettier_config(ctx)
    local root = vim.fs.root(ctx.buf, prettier_configs)
    return root ~= nil
end

return {
    -- Plantilla generada dinámicamente a partir de `defaults`
    init_config = {
        filename = ".prettierrc",
        content = vim.json.encode(defaults),
    },

    -- Mapeo de filetypes a usar Prettier
    formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        svelte = { "prettier" },
        astro = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
    },

    -- Sobreescritura nativa de Prettier
    formatters = {
        prettier = {
            prefer_local = "node_modules/.bin",
            require_cwd = false,

            -- Banderas inyectadas dinámicamente desde `defaults` cuando no hay config local
            prepend_args = function(self, ctx)
                if has_local_prettier_config(ctx) then
                    return {}
                end

                return {
                    "--no-config",
                    "--tab-width",
                    tostring(defaults.tabWidth),
                    "--use-tabs",
                    tostring(defaults.useTabs),
                    "--semi",
                    tostring(defaults.semi),
                    "--single-quote",
                    tostring(defaults.singleQuote),
                    "--trailing-comma",
                    defaults.trailingComma,
                }
            end,

            options = {
                ft_parsers = {
                    javascript = "babel",
                    javascriptreact = "babel",
                    typescript = "typescript",
                    typescriptreact = "typescript",
                    vue = "vue",
                    html = "html",
                    css = "css",
                    scss = "scss",
                    json = "json",
                    yaml = "yaml",
                },
            },
        },
    },
}
