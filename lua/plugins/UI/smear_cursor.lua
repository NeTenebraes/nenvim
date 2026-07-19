local ok, smear = pcall(require, "smear_cursor")
if not ok then
	return
end

-- =========================================================
-- CONFIGURACIÓN DE PERFILES
-- Opciones disponibles: "default", "snappy", "smooth", "fire"
-- =========================================================
local ACTIVE_PROFILE = "fire"

local profiles = {
	default = {
		smear_between_buffers = true,
		smear_between_neighbor_lines = true,
		scroll_buffer_space = true,
		smear_insert_mode = true,
	},

	snappy = {
		stiffness = 0.8,
		trailing_stiffness = 0.6,
		stiffness_insert_mode = 0.7,
		trailing_stiffness_insert_mode = 0.7,
		damping = 0.95,
		damping_insert_mode = 0.95,
		distance_stop_animating = 0.5,
		time_interval = 7,
	},

	smooth = {
		stiffness = 0.5,
		trailing_stiffness = 0.5,
		matrix_pixel_threshold = 0.5,
	},

	fire = {
		cursor_color = "#ff007f",
		particles_enabled = true,
		stiffness = 0.5,
		trailing_stiffness = 0.2,
		trailing_exponent = 5,
		damping = 0.6,
		gradient_exponent = 0,
		gamma = 1,

		-- ESTO EVITA QUE ESTORBE AL TEXTO:
		never_draw_over_target = true, -- Fuerza a que el texto donde cae tu cursor SIEMPRE se lea
		hide_target_hack = true, -- Evita que el cursor real parpadee o se duplique

		-- EL ALMA DEL FUEGO (Conserva el comportamiento de llama real):
		particle_spread = 1.2, -- Dispersión amplia para mantener la forma de llamarada
		particles_per_second = 350, -- Bastantes partículas para que la llama se vea densa
		particles_per_length = 35, -- Buena densidad al saltar de línea
		particle_max_lifetime = 300, -- Reducido a 300ms (antes 800): Se desvanece rápido antes de estorbar

		-- FÍSICAS DE ASCENSO (El fuego sube):
		particle_max_initial_velocity = 15, -- Fuerza de salida para que las chispas vuelen
		particle_velocity_from_cursor = 0.5,
		particle_damping = 0.15, -- Resistencia baja para que las chispas fluyan suaves
		particle_gravity = 40, -- Gravedad positiva (fuego sube). Si quieres que caiga usa -40.
		min_distance_emit_particles = 0, -- Genera fuego incluso con movimientos mínimos
	},
}

-- Aplicamos el perfil seleccionado
local selected_config = profiles[ACTIVE_PROFILE] or profiles.default
smear.setup(selected_config)
