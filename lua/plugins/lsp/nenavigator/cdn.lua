local M = {}

M._cache = {}

local function get_cache_dir()
    local dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "nenavigator_cdn")
    vim.fn.mkdir(dir, "p")
    return dir
end

local function get_json_db_path(file_path)
    local hash = vim.fn.sha256(file_path)
    return vim.fs.joinpath(vim.fn.stdpath("data"), "nenavigator_db", hash .. ".json")
end

local function load_disk_db(db_path)
    local f = io.open(db_path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    local ok, decoded = pcall(vim.json.decode, content)
    return ok and decoded or nil
end

local function save_disk_db(db_path, data)
    vim.fn.mkdir(vim.fs.dirname(db_path), "p")
    local f = io.open(db_path, "w")
    if f then
        f:write(vim.json.encode(data))
        f:close()
    end
end

local function parse_css_to_index(full_css)
    local index = {}

    for selector, body in full_css:gmatch("([^{}]+)%{([^{}]+)%}") do
        local clean_sel = vim.trim(selector)
        if not clean_sel:match(":root") and not clean_sel:match("^%s*%*%s*$") then
            local decls = {}
            for decl in body:gmatch("[^;]+") do
                if not decl:match("^%s*%-%-") then
                    local prop, val = decl:match("^%s*([^:]+):%s*(.*)$")
                    if prop and val then
                        table.insert(decls, string.format("  %s: %s;", vim.trim(prop), vim.trim(val)))
                    end
                end
            end

            if #decls > 0 then
                local formatted_block = string.format("%s {\n%s\n}", clean_sel, table.concat(decls, "\n"))
                for class_name in clean_sel:gmatch("%.([%w_-]+)") do
                    index[class_name] = index[class_name] or {}
                    if not vim.tbl_contains(index[class_name], formatted_block) then
                        table.insert(index[class_name], formatted_block)
                    end
                end
            end
        end
    end
    return index
end

function M.get_index(file_path)
    if M._cache[file_path] then
        return M._cache[file_path]
    end

    local db_path = get_json_db_path(file_path)
    local disk_cache = load_disk_db(db_path)
    if disk_cache then
        M._cache[file_path] = disk_cache
        return disk_cache
    end

    local lines = vim.fn.readfile(file_path)
    if not lines or #lines == 0 then return {} end

    local index = parse_css_to_index(table.concat(lines, " "))
    save_disk_db(db_path, index)
    M._cache[file_path] = index

    return index
end

function M.fetch(url, cb)
    local filename = url:gsub("[^%w]", "_") .. ".css"
    local cache_path = vim.fs.joinpath(get_cache_dir(), filename)

    if vim.uv.fs_stat(cache_path) then
        cb(cache_path)
        return
    end

    local cmd = vim.fn.executable("curl") == 1 and { "curl", "-sSL", "-o", cache_path, url }
             or vim.fn.executable("wget") == 1 and { "wget", "-q", "-O", cache_path, url } or nil

    if not cmd then cb(nil) return end

    vim.notify("NeNavigator: Descargando estilos externos (" .. (url:match("([^/]+%.css)") or "CDN") .. ")...")
    vim.system(cmd, {}, function(obj)
        vim.schedule(function()
            cb(obj.code == 0 and vim.uv.fs_stat(cache_path) and cache_path or nil)
        end)
    end)
end

function M.extract_class(file_path, selector)
    local index = M.get_index(file_path)
    local blocks = index[selector]
    return blocks and table.concat(blocks, "\n\n") or nil
end

return M