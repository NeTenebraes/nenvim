-- =========================================================
-- lua/plugins/lsp/formatters/lua.lua
-- Configuración de StyLua (4 espacios)
-- =========================================================

return {
    formatters_by_ft = {
        lua = { "stylua" },
    },

    formatters = {
        stylua = {
            prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
        },
    },
}
