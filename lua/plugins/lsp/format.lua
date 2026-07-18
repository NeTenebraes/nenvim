-- =========================================================
-- plugins/lsp/format.lua
-- Centralized Code Formatting Configuration (Conform.nvim)
-- =========================================================

local ok_conform, conform = pcall(require, "conform")
if not ok_conform then
  return
end

conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },

    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    vue = { "prettier" },
    svelte = { "prettier" },
    astro = { "prettier" },

    html = { "prettier" },
    css = { "prettier" },      
    scss = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },

    markdown = { "prettier" },
    toml = { "taplo" },

    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },

    c = { "clang-format" },
    cpp = { "clang-format" },
    java = { "google-java-format" },
  },

  formatters = {
    prettier = {
      options = {
        ft_parsers = {
          javascript = "babel",
          typescript = "typescript",
          javascriptreact = "babel",
          typescriptreact = "typescript",
          vue = "vue",
          html = "html",
          css = "css",
          json = "json",
          markdown = "markdown",
        },
      },
      args = function(_, ctx)
        local default_args = { "--stdin-filepath", "$FILENAME" }
        if vim.tbl_contains({ "javascript", "typescript", "javascriptreact", "typescriptreact", "css", "html", "json", "yaml", "scss" }, ctx.ft) then
          vim.list_extend(default_args, { "--tab-width", "4" })
        end
        if ctx.ft == "markdown" then
          vim.list_extend(default_args, { "--print-width", "80", "--prose-wrap", "always" })
        end
        if ctx.ft == "html" then
          vim.list_extend(default_args, { "--print-width", "120", "--html-whitespace-sensitivity", "ignore" })
        end
        return default_args
      end,
    },
  },

  format_on_save = {
    timeout_ms = 2000,
    lsp_fallback = true,
  },
})