local lint = require("lint")

-- 1. Ruta del archivo fallback en el directorio temporal/state de Neovim
local tmp_config = vim.fn.stdpath("state") .. "/stylelintrc_fallback.json"

-- 2. Aseguramos que el archivo en /tmp exista
if vim.fn.filereadable(tmp_config) == 0 then
    local f = io.open(tmp_config, "w")
    if f then
        f:write('{\n  "rules": {}\n}\n')
        f:close()
    end
end

lint.linters_by_ft.css = { "stylelint" }
lint.linters_by_ft.scss = { "stylelint" }

-- 3. Lista de nombres de archivos de configuración comunes de Stylelint
local stylelint_configs = {
    ".stylelintrc",
    ".stylelintrc.json",
    ".stylelintrc.yaml",
    ".stylelintrc.yml",
    ".stylelintrc.js",
    ".stylelintrc.cjs",
    ".stylelintrc.mjs",
    "stylelint.config.js",
    "stylelint.config.cjs",
    "stylelint.config.mjs",
}

-- 4. Configuramos los argumentos de Stylelint de forma dinámica
lint.linters.stylelint.args = {
    "--formatter",
    "json",
    "--stdin",
    "--stdin-filename",
    function()
        return vim.api.nvim_buf_get_name(0)
    end,
    function()
        -- Busca si existe algún archivo de configuración en la raíz del proyecto o carpetas superiores
        local project_config = vim.fs.find(stylelint_configs, {
            upward = true,
            path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        })[1]

        -- Si encontró una config en el proyecto, retornamos "--config" con su ruta
        if project_config then
            return "--config=" .. project_config
        end

        -- Si no encontró nada en el proyecto, usamos la de /tmp
        return "--config=" .. tmp_config
    end,
}
