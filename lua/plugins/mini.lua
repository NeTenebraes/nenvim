-- =========================================================
-- lua/plugins/mini.lua
-- Configuración unificada, limpia y modular de mini.nvim
-- =========================================================

-- Tabla de configuración de todos tus módulos de mini.nvim
local modules = {
	-- Módulos con configuración por defecto (se cargan con {})
surround = {
        mappings = {
            add            = 'Sa', -- Añadir envoltura (Normal y Visual)
            delete         = 'Sd', -- Borrar envoltura
            replace        = 'Sr', -- Reemplazar envoltura
            find           = 'Sf', -- Buscar adelante
            find_left      = 'SF', -- Buscar atrás
            highlight      = 'Sh', -- Resaltar
            update_n_lines = 'Sn', -- Cambiar líneas evaluadas
        },
    },
	ai = {},
	comment = {},
	pairs = {},
	splitjoin = {},
	bufremove = {},
	align = {},

	move = {
		options = {
			reindent_linewise = true,
		},
	},

	input = {
		window = {
			config = { border = "rounded" },
		},
	},
}

-- Bucle dinámico para cargar y configurar cada módulo de forma segura
for name, config in pairs(modules) do
	local ok, module = pcall(require, "mini." .. name)
	if ok then
		local opts = type(config) == "function" and config() or config
		module.setup(opts)
	end
end
