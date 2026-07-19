-- ============================================================================
-- MASON
-- ============================================================================

vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

local ok_mason, mason = pcall(require, "mason")
if not ok_mason then
  vim.notify("mason.nvim no está instalado", vim.log.levels.ERROR)
  return
end

mason.setup({
  ui = {
    border = "rounded",
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

local ok_mti, mti = pcall(require, "mason-tool-installer")
if ok_mti then
  mti.setup({
    ensure_installed = {
      "astro-language-server",
      "bash-language-server",
      "clangd",
      "css-lsp",
      "emmet-language-server",
      "html-lsp",
      "json-lsp",
      "lua-language-server",
      "marksman",
      "prisma-language-server",
      "basedpyright",
      "svelte-language-server",
      "tailwindcss-language-server",
      "taplo",
      "vue-language-server",
      "vtsls",
      "yaml-language-server",

      "prettier",
      "prettierd",
      "stylua",
      "black",
      "isort",
      "ruff",
      "shfmt",
      "clang-format",
      "shellcheck",
      "markdownlint",
      "stylelint",

      "bash-debug-adapter",
      "codelldb",
      "debugpy",
      "js-debug-adapter",
    },
    run_on_start = true,
    auto_update = true,
  })
end

-- ============================================================================
-- CAPABILITIES GLOBALES
-- ============================================================================

local capabilities = vim.lsp.protocol.make_client_capabilities()

local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Si notas lag en workspaces grandes, deja esto activado:
if capabilities.workspace then
  capabilities.workspace.didChangeWatchedFiles = nil
end

vim.lsp.config("*", {
  capabilities = capabilities,
  root_markers = {
    ".git",
  },
})

-- ============================================================================
-- DIAGNÓSTICOS
-- ============================================================================

vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
    },
  },
})

-- ============================================================================
-- SERVERS
-- ============================================================================

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
  root_markers = {
    "tsconfig.json",
    "jsconfig.json",
    "package.json",
    ".git",
  },
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
})

vim.lsp.config("astro", {
  cmd = { "astro-ls", "--stdio" },
  filetypes = { "astro" },
  root_markers = {
    "astro.config.mjs",
    "astro.config.ts",
    "package.json",
    ".git",
  },
  init_options = {
    typescript = {
      tsdk = vim.fn.stdpath("data") .. "/mason/packages/typescript-language-server/node_modules/typescript/lib",
    },
  },
})

vim.lsp.config("svelte", {
  cmd = { "svelteserver", "--stdio" },
  filetypes = { "svelte" },
  root_markers = {
    "svelte.config.js",
    "svelte.config.ts",
    "package.json",
    ".git",
  },
})

vim.lsp.config("volar", {
  cmd = { "vue-language-server", "--stdio" },
  filetypes = { "vue" },
  root_markers = {
    "vue.config.js",
    "vue.config.ts",
    "vite.config.js",
    "vite.config.ts",
    "package.json",
    ".git",
  },
})

vim.lsp.config("html", {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html", "templ" },
  root_markers = { ".git", "package.json" },
})

vim.lsp.config("cssls", {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_markers = { ".git", "package.json" },
})

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

vim.lsp.config("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git", "package.json" },
})

-- ============================================================================
-- SERVERS (PYTHON SIN SPAM DE PROGRESO)
-- ============================================================================

vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    ".git",
  },
  -- Intercepta y filtra las notificaciones repetitivas de progreso
  handlers = {
    ["$/progress"] = function(err, result, ctx)
      if result.token == (vim.g.basedpyright_progress_token or result.token) then
        vim.g.basedpyright_progress_token = result.token
        vim.lsp.handlers["$/progress"](err, result, ctx)
      end
    end,
  },
  settings = {
    basedpyright = {
      disableTaggedHints = true,
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "basic",
      },
    },
  },
})

vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    ".git",
  },
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".git",
  },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = { enable = false },
    },
  },
})

-- ============================================================================
-- ENABLE
-- ============================================================================
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
"basedpyright", -- <-- CAMBIADO
  "ruff",
  "lua_ls",
})

-- ============================================================================
-- DETECCIÓN AUTOMÁTICA DE LSP AL RENOMBRAR / GUARDAR PRIMERA VEZ
-- ============================================================================

local lsp_trigger_group = vim.api.nvim_create_augroup("LspTriggerOnRename", { clear = true })

vim.api.nvim_create_autocmd({ "BufFilePost", "BufWritePost" }, {
  group = lsp_trigger_group,
  callback = function(ev)
    local buf = ev.buf
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname == "" then return end

    local detected_ft = vim.filetype.match({ filename = bufname })
    if detected_ft and detected_ft ~= vim.bo[buf].filetype then
      vim.bo[buf].filetype = detected_ft
    end

    vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      
      local clients = vim.lsp.get_clients({ bufnr = buf })
      
      for _, client in ipairs(clients) do
        -- Forzar el re-attach del cliente para que actualice las capabilities del buffer
        vim.lsp.buf_attach_client(buf, client.id)
      end
    end)
  end,
})