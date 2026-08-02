nmap("K", function()
    local ok_otter, otter = pcall(require, "otter")
    if ok_otter then
        -- ask_hover() es inteligente: si hay código inyectado lo usa, si no, delega automáticamente
        otter.ask_hover()
    else
        local ok_noice, noice = pcall(require, "noice")
        if ok_noice then
            noice.lsp.hover()
        else
            vim.lsp.buf.hover()
        end
    end
end, "LSP / Otter Hover Docs")