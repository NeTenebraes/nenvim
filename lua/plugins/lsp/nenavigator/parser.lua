local M = {}

function M.get_selector_under_cursor()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
    if line == "" then return nil end

    local allowed = "[%w_-]"
    local start_col = col
    while start_col > 1 and line:sub(start_col - 1, start_col - 1):match(allowed) do
        start_col = start_col - 1
    end

    local end_col = col
    while end_col <= #line and line:sub(end_col, end_col):match(allowed) do
        end_col = end_col + 1
    end

    local sel = line:sub(start_col, end_col - 1):gsub("^%.", ""):gsub("^#", "")
    return sel ~= "" and sel or nil
end

function M.get_linked_css_files(bufnr, cdn_module, cb)
    local lines = vim.api.nvim_buf_get_lines(bufnr or 0, 0, -1, false)
    local root = vim.fs.root(bufnr or 0, { ".git", "package.json" }) or vim.fn.getcwd()
    local base = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr or 0))
    if base == "" then base = vim.fn.getcwd() end

    local files, seen = {}, {}
    local pending = 0

    local function done()
        if pending == 0 then cb(files) end
    end

    for _, line in ipairs(lines) do
        if line:find("<link") and line:find("stylesheet") then
            for href in line:gmatch('href%s*=%s*["' .. "'" .. ']([^"' .. "'" .. ']+)["' .. "'" .. ']') do
                if href:match("^https?://") then
                    pending = pending + 1
                    cdn_module.fetch(href, function(path)
                        pending = pending - 1
                        if path and not seen[path] then
                            seen[path] = true
                            table.insert(files, path)
                        end
                        done()
                    end)
                else
                    local path = href:sub(1, 1) == "/" and (root .. href) or (base .. "/" .. href)
                    path = vim.fs.normalize(path)
                    if vim.uv.fs_stat(path) and not seen[path] then
                        seen[path] = true
                        table.insert(files, path)
                    end
                end
            end
        end
    end

    done()
end

return M