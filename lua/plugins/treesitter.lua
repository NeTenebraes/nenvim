-- =========================================================
-- lua/plugins/treesitter.lua (Neovim 0.12)
-- =========================================================

-- Lista masiva de lenguajes a asegurar/instalar
local parsers = {
    -- Base / Vim
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",

    -- Shell & Configs
    "bash",
    "awk",
    "make",
    "cmake",
    "toml",
    "yaml",
    "json",
    "regex",
    "diff",
    "gitignore",
    "gitcommit",

    -- Sistemas & Compilados
    "c",
    "cpp",
    "rust",
    "go",
    "zig",
    "python",
    "java",

    -- Web / Frontend
    "html",
    "css",
    "scss",
    "javascript",
    "typescript",
    "tsx",
    "svelte",
    "vue",
    "astro",
    "graphql",

    -- Base de datos & DevOps
    "sql",
    "dockerfile",
    "xml",
}

local ok_ts, ts = pcall(require, "nvim-treesitter")
if not ok_ts then
    return
end

-- 1. Definir directorio nativo
local install_dir = vim.fn.stdpath("data") .. "/site"
vim.opt.runtimepath:append(install_dir)

ts.setup({
    install_dir = install_dir,
})

-- 2. Instalador automático sin bloquear el arranque (no-op si ya existen)
vim.schedule(function()
    pcall(function()
        ts.install(parsers, { summary = false })
    end)
end)

-- 3. Autocomando para activar Resaltado e Indentación por FileType
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
    callback = function(ev)
        local buftype = vim.bo[ev.buf].buftype
        local ignore_ft = {
            "help",
            "qf",
            "checkhealth",
            "snacks_picker_input",
            "snacks_picker_list",
        }

        if buftype ~= "" or vim.tbl_contains(ignore_ft, ev.match) then
            return
        end

        -- Inicia el resaltado nativo
        pcall(vim.treesitter.start)

        -- Indentación de nvim-treesitter
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

-- 4. Plegado (Folds)
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldmethod = "expr"
vim.opt.foldenable = false
vim.opt.foldlevel = 99

-- =========================================================
-- 👑 STICKY SCROLL
-- =========================================================
local ok_context, context = pcall(require, "treesitter_context")
if ok_context then
    context.setup({
        enable = true,
        max_lines = 4,
        min_window_height = 0,
        line_numbers = true,
        multiline_threshold = 1,
        trim_scope = "outer",
        mode = "cursor",
    })
end

-- =========================================================
-- 🏷️ AUTO CLOSE TAG
-- =========================================================
local ok_autotag, autotag = pcall(require, "nvim-ts-autotag")
if ok_autotag then
    autotag.setup({
        opts = {
            enable_close = true,
            enable_rename = true,
            enable_close_on_slash = true,
        },
    })
end
