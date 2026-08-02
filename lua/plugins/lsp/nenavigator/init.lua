local M = {}

-- Módulos cargados explícitamente desde tu estructura de carpetas
local cdn = require("plugins.lsp.nenavigator.cdn")
local parser = require("plugins.lsp.nenavigator.parser")
local picker = require("plugins.lsp.nenavigator.picker")

M.config = {
    html_filetypes = { "html", "php", "astro", "vue", "jsx", "tsx", "svelte" },
    keymaps = {
        edit = "<leader>cj",
        hover = "<leader>ck",
    },
    float = {
        width = 0.65,
        height = 0.60,
        border = "rounded",
    },
}

function M.hover_class()
    local sel = parser.get_selector_under_cursor()
    if not sel then
        vim.notify("NeNavigator: No hay una clase bajo el cursor", vim.log.levels.WARN)
        return
    end

    parser.get_linked_css_files(0, cdn, function(files)
        local markdown_lines = {}

        for _, file in ipairs(files) do
            local is_cdn = file:match("nenavigator_cdn") or file:match("%.min%.css$")
            local block = nil

            if is_cdn then
                block = cdn.extract_class(file, sel)
            else
                local lines = vim.fn.readfile(file)
                if lines then
                    for _, line in ipairs(lines) do
                        if line:match("%." .. sel) then
                            block = line
                            break
                        end
                    end
                end
            end

            if block then
                local source_name = is_cdn and "🌐 CDN Bootstrap / External" or ("📄 " .. vim.fn.fnamemodify(file, ":."))
                table.insert(markdown_lines, string.format("### `%s`", source_name))
                table.insert(markdown_lines, "```css\n" .. block .. "\n```\n")
            end
        end

        picker.show_hover(sel, markdown_lines, M.config.float)
    end)
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})

    local group = vim.api.nvim_create_augroup("NeNavigatorAttach", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = M.config.html_filetypes,
        callback = function(ev)
            local opts_map = { buffer = ev.buf, silent = true, nowait = true }
            vim.keymap.set("n", M.config.keymaps.hover, M.hover_class, opts_map)
        end,
    })
end

return M