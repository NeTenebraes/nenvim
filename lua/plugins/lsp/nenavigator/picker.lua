local M = {}

function M.show_hover(sel, markdown_lines, config)
    if not markdown_lines or #markdown_lines == 0 then
        vim.notify("NeNavigator: No se encontró la regla para ." .. sel, vim.log.levels.WARN)
        return
    end

    vim.lsp.util.open_floating_preview(markdown_lines, "markdown", {
        border = config.border or "rounded",
        focusable = true,
        max_width = math.floor(vim.o.columns * (config.width or 0.65)),
        max_height = math.floor(vim.o.lines * (config.height or 0.50)),
    })
end

function M.open_float_file(path, line, col, config)
    local width = math.floor(vim.o.columns * (config.width or 0.65))
    local height = math.floor(vim.o.lines * (config.height or 0.60))
    local row = math.floor((vim.o.lines - height) / 2)
    local colpos = math.floor((vim.o.columns - width) / 2)

    local buf = vim.fn.bufadd(path)
    vim.fn.bufload(buf)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = row,
        col = colpos,
        width = width,
        height = height,
        style = "minimal",
        border = config.border or "rounded",
        title = string.format(" 📝 %s [Línea %d] ", vim.fn.fnamemodify(path, ":."), line),
        title_pos = "center",
    })

    vim.api.nvim_win_set_cursor(win, { line, math.max(0, (col or 1) - 1) })

    local opts = { buffer = buf, silent = true, nowait = true }
    vim.keymap.set("n", "q", "<cmd>close<CR>", opts)
    vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", opts)
end

function M.open_picker(sel, results, config)
    if not results or #results == 0 then
        vim.notify("NeNavigator: No se encontraron coincidencias para ." .. sel, vim.log.levels.WARN)
        return
    end

    if #results == 1 then
        M.open_float_file(results[1].path, results[1].line, results[1].column, config)
        return
    end

    local ok, Snacks = pcall(require, "snacks")
    if ok and Snacks and Snacks.picker then
        local items = {}
        for _, r in ipairs(results) do
            table.insert(items, {
                text = string.format("%s:%d  %s", vim.fn.fnamemodify(r.path, ":."), r.line, r.text),
                file = r.path,
                pos = { r.line, math.max(0, r.column - 1) },
            })
        end

        Snacks.picker({
            title = "CSS ." .. sel,
            items = items,
            confirm = function(picker_inst, item)
                picker_inst:close()
                M.open_float_file(item.file, item.pos[1], item.pos[2] + 1, config)
            end,
        })
        return
    end

    vim.fn.setqflist({}, " ", {
        title = "NeNavigator ." .. sel,
        items = vim.tbl_map(function(r)
            return { filename = r.path, lnum = r.line, col = r.column, text = r.text }
        end, results),
    })
    vim.cmd("copen")
end

return M