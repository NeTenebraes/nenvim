-- ==========================================================================
-- nvim-html-css Configuration
-- ==========================================================================
local status_ok, html_css = pcall(require, "html-css")
if not status_ok then
    return
end

html_css.setup({
    -- Se restringe a tipos de archivo estrictamente web/markup.
    -- Remover "javascript" evita el crash de caché de IDs (nil index) en JS puro.
    enable_on = {
        "html",
        "css",
    },

    -- Mapeos para Go to Definition y Hover
    handlers = {
        definition = {
            bind = "gd",
        },
        hover = {
            bind = "K",
            wrap = true,
            border = "rounded",
            position = "cursor",
        },
    },

    documentation = {
        auto_show = true,
    },

    -- Configuración de la ventana flotante Peek
    peek = {
        enabled = true,
        border = "rounded",
        position = "center",
        width = 0.5,
        height = 0.5,
        focus = true,
        style = "minimal",
    },

    style_sheets = {},
})

-- Mapeo para la función Peek (revisar definición CSS en ventana flotante)
vim.keymap.set("n", "<leader>cp", "<cmd>HtmlCssPeek<CR>", {
    desc = "Peek CSS Source",
    silent = true,
})
