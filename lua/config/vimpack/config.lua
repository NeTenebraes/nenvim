-- ==========================================================================
-- vimpack: config.lua (Strict & Isolated Plugin Configuration Loader)
-- ==========================================================================
local M = {}

-- ==========================================================================
-- USER-CONFIGURABLE MESSAGES (Localization)
-- ==========================================================================
M.messages = {
	load_error = "❌ Error loading [%s]: %s",
}

M.modules = {
	-- Core Utilities (Directos en lua/plugins/)
	"plugins.treesitter",
	"plugins.mini",
	"plugins.snacks",
	"plugins.flash",
	"plugins.live-server",
	"plugins.multi_cursor",
	"plugins.Debug",

	-- Interfaz Gráfica (Físicamente en lua/plugins/UI/)
	"plugins.UI.bufferline",
	"plugins.UI.ccc",
	"plugins.UI.devicons",
	"plugins.UI.gitsigns",
	"plugins.UI.lualine",
	"plugins.UI.noice",
	"plugins.UI.rainbow",
	"plugins.UI.render-markdown",
	"plugins.UI.smear_cursor",

	-- Entorno LSP / Configs de Desarrollo (En lua/plugins/lsp/)
	"plugins.lsp.init",
	"plugins.lsp.formatter",
	"plugins.lsp.linter",
	"plugins.lsp.cmp.init",
	"plugins.lsp.dap.init",
}

M.load_all = function()
	for _, module in ipairs(M.modules) do
		local ok, err = pcall(require, module)
		if not ok then
			vim.schedule(function()
				vim.notify(string.format(M.messages.load_error, module, err), vim.log.levels.ERROR)
			end)
		end
	end
end

return M
