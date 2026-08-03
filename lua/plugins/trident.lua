local M = {}

local ns_id = vim.api.nvim_create_namespace("trident_ui")
local hl_ns_id = vim.api.nvim_create_namespace("trident_match_hl")
local last_selected = nil

local function normalize_path(path)
    if not path or path == "" then
        return ""
    end
    local abs = vim.fn.fnamemodify(path, ":p")
    return (vim.uv or vim.loop).fs_realpath(abs) or abs
end

-- Captura el término limpiando puntos iniciales para evitar romper la regex
local function get_target_word()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1

    local start_col = col
    while start_col > 1 and line:sub(start_col - 1, start_col - 1):match("[%w_%-%.]") do
        start_col = start_col - 1
    end

    local end_col = col
    while end_col <= #line and line:sub(end_col, end_col):match("[%w_%-%.]") do
        end_col = end_col + 1
    end

    if start_col >= end_col then
        return nil
    end

    local raw_word = line:sub(start_col, end_col - 1)
    return raw_word:gsub("^%.+", "")
end

local function get_mode_filter_label(mode)
    local cur_file = vim.fn.expand("%:t")
    local cur_ext = vim.fn.expand("%:e")

    if mode == "exclude_file" then
        return cur_file ~= "" and string.format("EXCLUDE: %s", cur_file) or "EXCLUDE CURRENT FILE"
    elseif mode == "exclude_ext" then
        return cur_ext ~= "" and string.format("EXCLUDE ALL: .%s", cur_ext) or "EXCLUDE EXTENSION"
    else
        return "ALL FILES"
    end
end

local function close_floating_editor(win, buf)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified then
        local choice = vim.fn.confirm("You have unsaved changes. Are you sure you want to quit?", "&Yes\n&No", 2)
        if choice ~= 1 then
            return false
        end
    end

    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
    return true
end

-- Floating editor window
local function open_floating_editor(filepath, lnum, col_idx, filter_label)
    last_selected = { file = filepath, lnum = lnum, col = col_idx, label = filter_label }

    local abs_path = vim.fn.fnamemodify(filepath, ":p")
    local buf = vim.fn.bufadd(abs_path)
    vim.fn.bufload(buf)

    vim.api.nvim_buf_clear_namespace(buf, hl_ns_id, 0, -1)

    local ft = vim.filetype.match({ filename = abs_path, buf = buf })
    if ft then
        vim.bo[buf].filetype = ft
    end

    local width = math.floor(vim.o.columns * 0.60)
    local height = math.floor(vim.o.lines * 0.60)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local fname = vim.fn.fnamemodify(filepath, ":t")

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = string.format(" %s ", fname),
        title_pos = "center",
        footer = string.format(" %s ", filter_label),
        footer_pos = "center",
    })

    vim.wo[win].number = true
    vim.wo[win].cursorline = true

    pcall(vim.treesitter.start, buf, ft)
    vim.api.nvim_exec_autocmds("BufReadPost", { buffer = buf })

    if lnum and tonumber(lnum) > 0 then
        local line_count = vim.api.nvim_buf_line_count(buf)
        local target_line = math.min(tonumber(lnum), line_count)
        local target_col = math.max(0, tonumber(col_idx) or 0)

        vim.api.nvim_win_set_cursor(win, { target_line, target_col })
        vim.api.nvim_win_call(win, function()
            vim.cmd("normal! zz")
        end)
    end

    local opts = { buffer = buf, silent = true }
    vim.keymap.set("n", "q", function()
        close_floating_editor(win, buf)
    end, opts)
    vim.keymap.set("n", "<Esc>", function()
        close_floating_editor(win, buf)
    end, opts)
end

function M.open_last_buffer()
    if not last_selected then
        vim.notify("Trident: No previous buffer recorded", vim.log.levels.WARN)
        return
    end
    open_floating_editor(
        last_selected.file,
        last_selected.lnum,
        last_selected.col,
        last_selected.label or "LAST BUFFER"
    )
end

-- Dual Split Menu
local function open_selection_menu(results, filter_label, word)
    local total_width = math.floor(vim.o.columns * 0.70)
    local total_height = 10
    local row = math.floor((vim.o.lines - total_height) / 2)

    local list_width = math.floor(total_width * 0.35)
    local preview_width = total_width - list_width - 2

    local list_col = math.floor((vim.o.columns - total_width) / 2)
    local preview_col = list_col + list_width + 2

    -- 1. LEFT PANEL
    local list_buf = vim.api.nvim_create_buf(false, true)
    local list_lines = {}
    local max_fname_len = 0

    for _, r in ipairs(results) do
        local fn = vim.fn.fnamemodify(r.file, ":t")
        if #fn > max_fname_len then
            max_fname_len = #fn
        end
    end

    for _, r in ipairs(results) do
        local fname = vim.fn.fnamemodify(r.file, ":t")
        local pos_str = string.format("%d:%d", r.lnum, r.col + 1)
        table.insert(list_lines, string.format(" %-" .. max_fname_len .. "s  %s", fname, pos_str))
    end

    vim.api.nvim_buf_set_lines(list_buf, 0, -1, false, list_lines)

    local list_win = vim.api.nvim_open_win(list_buf, true, {
        relative = "editor",
        width = list_width,
        height = total_height,
        row = row,
        col = list_col,
        style = "minimal",
        border = "rounded",
        title = string.format(" Trident: %s ", word or ""),
        title_pos = "center",
        footer = string.format(" %s ", filter_label),
        footer_pos = "center",
    })

    for i, _ in ipairs(results) do
        local l_idx = i - 1
        vim.api.nvim_buf_add_highlight(list_buf, ns_id, "Directory", l_idx, 1, 1 + max_fname_len)
        vim.api.nvim_buf_add_highlight(list_buf, ns_id, "LineNr", l_idx, 1 + max_fname_len, -1)
    end

    vim.wo[list_win].cursorline = true
    vim.bo[list_buf].modifiable = false
    vim.bo[list_buf].bufhidden = "wipe"

    -- 2. RIGHT PANEL
    local preview_buf = vim.api.nvim_create_buf(false, true)
    local preview_win = vim.api.nvim_open_win(preview_buf, false, {
        relative = "editor",
        width = preview_width,
        height = total_height,
        row = row,
        col = preview_col,
        style = "minimal",
        border = "rounded",
        title = " Preview ",
        title_pos = "center",
    })

    local active_preview_buf = nil

    local function update_preview()
        if not vim.api.nvim_win_is_valid(list_win) then
            return
        end
        local cursor = vim.api.nvim_win_get_cursor(list_win)
        local item = results[cursor[1]]
        if not item then
            return
        end

        if active_preview_buf and vim.api.nvim_buf_is_valid(active_preview_buf) then
            vim.api.nvim_buf_clear_namespace(active_preview_buf, hl_ns_id, 0, -1)
        end

        local abs_path = vim.fn.fnamemodify(item.file, ":p")
        local p_buf = vim.fn.bufadd(abs_path)
        vim.fn.bufload(p_buf)
        active_preview_buf = p_buf

        local ft = vim.filetype.match({ filename = abs_path, buf = p_buf })
        if ft then
            vim.bo[p_buf].filetype = ft
        end

        vim.api.nvim_win_set_buf(preview_win, p_buf)
        vim.wo[preview_win].number = true
        vim.wo[preview_win].cursorline = true
        vim.wo[preview_win].wrap = false

        pcall(vim.treesitter.start, p_buf, ft)

        vim.api.nvim_buf_clear_namespace(p_buf, hl_ns_id, 0, -1)

        if item.lnum and item.lnum > 0 then
            local line_cnt = vim.api.nvim_buf_line_count(p_buf)
            local target = math.min(item.lnum, line_cnt)
            local target_col = math.max(0, item.col or 0)

            vim.api.nvim_win_set_cursor(preview_win, { target, target_col })
            vim.api.nvim_win_call(preview_win, function()
                vim.cmd("normal! zz")
            end)

            if word and #word > 0 then
                vim.api.nvim_buf_add_highlight(p_buf, hl_ns_id, "Search", target - 1, target_col, target_col + #word)
            end
        end

        vim.api.nvim_win_set_config(preview_win, {
            relative = "editor",
            width = preview_width,
            height = total_height,
            row = row,
            col = preview_col,
            title = string.format(" Preview: %s ", item.file),
            title_pos = "center",
        })
    end

    local augroup = vim.api.nvim_create_augroup("TridentPreviewSync", { clear = true })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = augroup,
        buffer = list_buf,
        callback = update_preview,
    })

    update_preview()

    local function cleanup_and_close()
        -- Comprobación de cambios sin guardar en la ventana de previsualización antes de cerrar
        if
            active_preview_buf
            and vim.api.nvim_buf_is_valid(active_preview_buf)
            and vim.bo[active_preview_buf].modified
        then
            local choice =
                vim.fn.confirm("You have unsaved changes in preview. Are you sure you want to quit?", "&Yes\n&No", 2)
            if choice ~= 1 then
                return false
            end
        end

        pcall(vim.api.nvim_del_augroup_by_id, augroup)
        if active_preview_buf and vim.api.nvim_buf_is_valid(active_preview_buf) then
            vim.api.nvim_buf_clear_namespace(active_preview_buf, hl_ns_id, 0, -1)
        end
        if vim.api.nvim_win_is_valid(list_win) then
            vim.api.nvim_win_close(list_win, true)
        end
        if vim.api.nvim_win_is_valid(preview_win) then
            vim.api.nvim_win_close(preview_win, true)
        end
        return true
    end

    local function confirm()
        local cursor = vim.api.nvim_win_get_cursor(list_win)
        local item = results[cursor[1]]
        if cleanup_and_close() then
            if item then
                open_floating_editor(item.file, item.lnum, item.col, filter_label)
            end
        end
    end

    local opts = { buffer = list_buf, silent = true }
    vim.keymap.set("n", "<CR>", confirm, opts)
    vim.keymap.set("n", "q", cleanup_and_close, opts)
    vim.keymap.set("n", "<Esc>", cleanup_and_close, opts)
end

-- Engine Core
function M.inspect_and_edit(mode)
    local word = get_target_word()
    if not word or word == "" then
        vim.notify("Trident: No valid word found under cursor", vim.log.levels.WARN)
        return
    end

    local filter_label = get_mode_filter_label(mode)
    local current_file_rel = vim.fn.expand("%:.")
    local current_file_abs = normalize_path(vim.api.nvim_buf_get_name(0))
    local current_ext = vim.fn.expand("%:e")

    local escaped_word = word:gsub("([%^%$%(%)%%%.%[%]%*%+\\%-%?])", "\\%1")
    local regex_pattern = string.format("(?<![\\w_-])%s(?![\\w_-])", escaped_word)

    local cmd_parts = { "rg", "--vimgrep", "-P" }

    if mode == "exclude_file" and current_file_rel ~= "" then
        table.insert(cmd_parts, string.format("-g '!%s'", current_file_rel))
    elseif mode == "exclude_ext" and current_ext ~= "" then
        table.insert(cmd_parts, string.format("-g '!*.%s'", current_ext))
    end

    table.insert(cmd_parts, vim.fn.shellescape(regex_pattern))
    table.insert(cmd_parts, "2>/dev/null")
    local cmd = table.concat(cmd_parts, " ")

    local handle = io.popen(cmd)
    if not handle then
        vim.notify("Trident: Failed to execute ripgrep command", vim.log.levels.ERROR)
        return
    end

    local results = {}
    for line in handle:lines() do
        local parts = vim.split(line, ":")
        if #parts >= 4 then
            local match_file = normalize_path(parts[1])
            local is_same_file = (match_file == current_file_abs)

            local include_match = true
            if mode == "exclude_file" and is_same_file then
                include_match = false
            elseif mode == "exclude_ext" and is_same_file then
                include_match = false
            end

            if include_match then
                local text_content = table.concat({ select(4, unpack(parts)) }, ":")
                table.insert(results, {
                    file = parts[1],
                    lnum = tonumber(parts[2]),
                    col = tonumber(parts[3]) - 1,
                    text_trim = vim.trim(text_content),
                })
            end
        end
    end
    handle:close()

    if #results == 0 then
        vim.notify(string.format("Trident: No matches found for '%s' [%s]", word, filter_label), vim.log.levels.WARN)
        return
    end

    if #results == 1 then
        open_floating_editor(results[1].file, results[1].lnum, results[1].col, filter_label)
    else
        open_selection_menu(results, filter_label, word)
    end
end

-- Keymaps
vim.keymap.set("n", "tt", function()
    M.inspect_and_edit("all")
end, { desc = "Trident: Peek All Files", silent = true })

vim.keymap.set("n", "tr", function()
    M.inspect_and_edit("exclude_file")
end, { desc = "Trident: Exclude Current File", silent = true })

vim.keymap.set("n", "te", function()
    M.inspect_and_edit("exclude_ext")
end, { desc = "Trident: Exclude Current Extension", silent = true })

vim.keymap.set("n", "tl", function()
    M.open_last_buffer()
end, { desc = "Trident: Open Last Buffer", silent = true })

return M
