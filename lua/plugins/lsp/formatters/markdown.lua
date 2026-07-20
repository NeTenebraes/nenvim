-- =========================================================
-- lua/plugins/lsp/formatters/markdown.lua
-- Configuración de mdformat a 80 columnas
-- =========================================================

return {
    formatters_by_ft = {
        markdown = { "mdformat" },
        ["markdown.mdx"] = { "mdformat" },
    },

    formatters = {
        mdformat = {
            prepend_args = { "--wrap", "80" },
        },
    },
}
