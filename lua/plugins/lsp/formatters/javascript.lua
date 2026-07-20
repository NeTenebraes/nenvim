-- =========================================================
-- lua/plugins/lsp/formatters/javascript.lua
-- Reglas de Prettier para JS / TS / Web (Sin .prettierrc)
-- =========================================================

return {
    -- 1. Mapeo de filetypes a usar Prettier
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

    -- 2. Sobreescritura nativa de Prettier
    formatters = {
        prettier = {
            -- A) Forzamos a Conform a ignorar archivos de configuración locales (.prettierrc)
            require_cwd = false,

            -- B) Pasamos las banderas globales directamente mediante prepend_args
            -- Conform se encarga automáticamente de agregar --stdin-filepath y manejar la entrada
            prepend_args = {
                "--no-config", -- Ignora .prettierrc o package.json
                "--tab-width",
                "4", -- Indentación global de 4 espacios
                "--use-tabs",
                "false", -- Usa espacios reales
            },

            -- C) Mapeo de parsers recomendado por Conform para evitar fallos de sintaxis
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
