local ok, lint = pcall(require, "lint")
if not ok then
  return
end

lint.linters_by_ft = {
  javascript = { "oxlint" },
  typescript = { "oxlint" },
  javascriptreact = { "oxlint" },
  typescriptreact = { "oxlint" },
  css = { "stylelint" },
  scss = { "stylelint" },
}

local group = vim.api.nvim_create_augroup("NvimLintConfig", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
  group = group,
  callback = function(args)
    if not vim.api.nvim_buf_is_valid(args.buf) then
      return
    end

    if vim.bo[args.buf].buftype ~= "" then
      return
    end

    vim.schedule(function()
      lint.try_lint()
    end)
  end,
})