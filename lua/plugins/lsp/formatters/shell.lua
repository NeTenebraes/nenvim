-- =========================================================
-- lua/plugins/lsp/formatters/shell.lua
-- Configuración de shfmt
-- =========================================================

return {
    formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
    },

    formatters = {
        shfmt = {
            prepend_args = { "-i", "4" },
        },
    },
}
