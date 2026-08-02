local ok_otter, otter = pcall(require, "otter")
if not ok_otter then
    return
end

otter.setup({
    buffers = {
        set_filetype = true,
        write_to_disk = false,
    },
    verbose = {
        no_code_found = false,
    },
})

-- Mapeo de filetypes y los lenguajes inyectados que quieres activar
local injected_languages = {
    html = { "javascript", "css" },
    astro = { "typescript", "javascript", "css" },
    svelte = { "typescript", "javascript", "css" },
    vue = { "typescript", "javascript", "css" },
    markdown = { "javascript", "typescript", "css", "python", "bash", "json" },
}

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("OtterMultiActivation", { clear = true }),
    pattern = vim.tbl_keys(injected_languages),
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local langs = injected_languages[ft]
        if langs then
            otter.activate(langs)
        end
    end,
})
