-- JS / TS (Vtsls)
vim.lsp.config("vtsls", {
    cmd = { "vtsls", "--stdio" },
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
    },
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
    on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end,
})

-- Astro
vim.lsp.config("astro", {
    cmd = { "astro-ls", "--stdio" },
    filetypes = { "astro" },
    root_markers = { "astro.config.mjs", "astro.config.ts", "package.json", ".git" },
    init_options = {
        typescript = {
            tsdk = vim.fn.stdpath("data") .. "/mason/packages/typescript-language-server/node_modules/typescript/lib",
        },
    },
})

-- Svelte
vim.lsp.config("svelte", {
    cmd = { "svelteserver", "--stdio" },
    filetypes = { "svelte" },
    root_markers = { "svelte.config.js", "svelte.config.ts", "package.json", ".git" },
})

-- Vue (Volar)
vim.lsp.config("volar", {
    cmd = { "vue-language-server", "--stdio" },
    filetypes = { "vue" },
    root_markers = { "vue.config.js", "vue.config.ts", "vite.config.js", "vite.config.ts", "package.json", ".git" },
})

-- HTML
vim.lsp.config("html", {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html", "templ" },
    root_markers = { ".git", "package.json" },
})

-- CSS
vim.lsp.config("cssls", {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    root_markers = { ".git", "package.json" },
})

-- TailwindCSS
vim.lsp.config("tailwindcss", {
    cmd = { "tailwindcss-language-server", "--stdio" },
    filetypes = {
        "html",
        "css",
        "scss",
        "sass",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "svelte",
        "astro",
    },
    root_markers = {
        "tailwind.config.js",
        "tailwind.config.ts",
        "postcss.config.js",
        "postcss.config.ts",
        "package.json",
        ".git",
    },
})

-- Emmet
vim.lsp.config("emmet_language_server", {
    cmd = { "emmet-language-server", "--stdio" },
    filetypes = {
        "html",
        "css",
        "scss",
        "sass",
        "less",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "svelte",
        "astro",
    },
    root_markers = { ".git", "package.json" },
})

-- JSON
vim.lsp.config("jsonls", {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { ".git", "package.json" },
})

-- Habilitar todos los de este módulo
vim.lsp.enable({
    "vtsls",
    "astro",
    "svelte",
    "volar",
    "html",
    "cssls",
    "tailwindcss",
    "emmet_language_server",
    "jsonls",
})
