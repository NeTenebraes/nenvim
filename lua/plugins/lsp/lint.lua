-- =========================================================
-- plugins/lsp/lint.lua
-- Centralized Linting Configuration (nvim-lint)
-- =========================================================

local ok_lint, lint = pcall(require, "lint")
if not ok_lint then
  return
end

-- 1. Mapeamos qué linters controlan cada tipo de archivo
lint.linters_by_ft = {
  javascript          = { "oxlint" },
  typescript          = { "oxlint" },
  javascriptreact     = { "oxlint" },
  typescriptreact     = { "oxlint" },
  
  -- Añadimos soporte para tu stack CSS/SCSS ya que oxlint solo ve JS/TS
  css                 = { "stylelint" },
  scss                = { "stylelint" },
}

-- 2. Personalizamos los argumentos de Oxlint para que use tu configuración estricta
if lint.linters.oxlint then
  lint.linters.oxlint.args = {
    "--format", "json",
    "--deny", "correctness",
    "--deny", "perf",
    "--deny", "style",
  }
end

-- 3. Autocomando inteligente: Evitamos saturar procesos usando un timer para debounce
local lint_group = vim.api.nvim_create_augroup("NvimLintConfig", { clear = true })
local timer = vim.loop.new_timer()

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "TextChanged", "TextChangedI" }, {
  group = lint_group,
  callback = function(args)
    if not vim.api.nvim_buf_is_valid(args.buf) or vim.bo[args.buf].buftype ~= "" then
      return
    end

    -- Debounce de 150ms: Si sigues tipeando, reinicia el reloj en lugar de abrir otro proceso
    timer:stop()
    timer:start(150, 0, vim.schedule_wrap(function()
      lint.try_lint()
    end))
  end,
})