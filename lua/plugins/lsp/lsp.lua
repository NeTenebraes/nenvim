-- ============================================================================
-- 1. CONFIGURACIÓN E INICIALIZACIÓN DE MASON
-- ============================================================================

-- Inyectar los binarios de Mason al PATH antes de que cargue cualquier cosa
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

-- Asegurar la instalación automatizada de herramientas externas
local ok_mti, mti = pcall(require, "mason-tool-installer")
if ok_mti then
  mti.setup({
    ensure_installed = {
      -- LSPs
      "astro-language-server", "bash-language-server", "clangd", "css-lsp",
      -- "cssmodules-language-server", "dockerfile-language-server", 
      "emmet-language-server", "html-lsp", "json-lsp", "lua-language-server",
      "marksman", "prisma-language-server", "pyright", "svelte-language-server",
      "tailwindcss-language-server", "taplo", "vue-language-server", "vtsls",
      "yaml-language-server",
      -- Formatters & Linters & DAP
      "prettier", "prettierd", "stylua", "black", "isort", "ruff", "shfmt",
      "clang-format", "shellcheck", "markdownlint", "stylelint",
      "bash-debug-adapter", "codelldb", "debugpy", "js-debug-adapter",
    },
    run_on_start = true,
    auto_update = false,
  })
end

-- ============================================================================
-- 2. CAPABILITIES (INTEGRACIÓN CON NVIM-CMP)
-- ============================================================================

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- ============================================================================
-- 3. UI Y CONFIGURACIÓN DE DIAGNÓSTICOS GLOBALES
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
-- 4. DICCIONARIO DE CONFIGURACIONES ESPECÍFICAS DE SERVIDORES (WEB OPTIMIZED)
-- ============================================================================

local servers = {
  -- JavaScript, TypeScript y React (JSX / TSX)
  vtsls = {
    cmd = { "vtsls", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    on_attach = function(client)
      -- Deshabilitar formateo para delegar en conform.nvim / prettier
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
  },

  -- Astro framework
  astro = {
    cmd = { "astro-ls", "--stdio" },
    filetypes = { "astro" },
    init_options = {
      typescript = {
        tsdk = vim.fn.stdpath("data") .. "/mason/packages/typescript-language-server/node_modules/typescript/lib",
      },
    },
  },

  -- Svelte
  svelte = {
    cmd = { "svelteserver", "--stdio" },
    filetypes = { "svelte" },
  },

  -- Vue (Volar)
  volar = {
    cmd = { "vue-language-server", "--stdio" },
    filetypes = { "vue" },
  },

  -- HTML estándar y plantillas
  html = {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html", "templ" },
  },

  -- CSS, SCSS y Less
  cssls = {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
  },

  -- Tailwind CSS (Inyección de clases en frameworks web)
  tailwindcss = {
    cmd = { "tailwindcss-language-server", "--stdio" },
    filetypes = { "html", "css", "scss", "sass", "javascriptreact", "typescriptreact", "vue", "svelte", "astro" },
  },

  -- Emmet (Expansión de snippets ultrarrápida en HTML/JSX/Frameworks)
  emmet_language_server = {
    cmd = { "emmet-language-server", "--stdio" },
    filetypes = { "html", "css", "scss", "sass", "less", "javascriptreact", "typescriptreact", "vue", "svelte", "astro" },
  },

  -- JSON y archivos de configuración estructurados
  jsonls = {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
  },

  -- Python (Corregido sin el argumento --mode)
  pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "openFilesOnly",
          typeCheckingMode = "basic",
        },
      },
    },
  },

  -- Lua (Entorno Neovim)
  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
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
  },
}

-- ============================================================================
-- 5. ORQUESTACIÓN NATIVA Y ARRANQUE (AUTOCMDS)
-- ============================================================================

local lsp_group = vim.api.nvim_create_augroup("NativeLspConfig", { clear = true })

for server_name, config in pairs(servers) do
  vim.api.nvim_create_autocmd("FileType", {
    group = lsp_group,
    pattern = config.filetypes,
    callback = function(ev)
      -- Combinar la config base con las capacidades de autocompletado
      local final_config = vim.tbl_deep_extend("force", {
        name = server_name,
        capabilities = capabilities,
        root_dir = vim.fs.root(ev.buf, {
          ".git",
          "package.json",
          "tsconfig.json",
          "jsconfig.json",
          "pyproject.toml",
          "setup.py",
          "Cargo.toml",
        }) or vim.fn.getcwd(),
      }, config)

      -- Arrancar o adjuntar el cliente LSP de manera nativa
      vim.lsp.start(final_config, { bufnr = ev.buf })
    end,
  })
end