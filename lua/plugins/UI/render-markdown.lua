local ok, render_md = pcall(require, "render-markdown")
if not ok then
	return
end

render_md.setup({
	-- Le dice al plugin que use los iconos ultraligeros de la suite mini
	anti_conceal = {
		enabled = true,
	},
	-- Configuración recomendada para integrarse perfectamente con mini.icons
	code = {
		sign = false,
		width = "block",
		right_pad = 4,
	},
	heading = {
		-- Iconos elegantes para los títulos (# H1, ## H2...)
		icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
	},
})
