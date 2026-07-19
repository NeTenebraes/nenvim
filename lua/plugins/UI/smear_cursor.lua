local ok, smear = pcall(require, "smear_cursor")
if not ok then
	return
end

-- =========================================================
-- CONFIGURACIÓN DE PERFILES
-- Opciones disponibles: "default", "snappy", "smooth", "fire"
-- =========================================================
local ACTIVE_PROFILE = "hyper_visor"

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
		never_draw_over_target = true,
		hide_target_hack = true,

		particle_spread = 1.2,
		particles_per_second = 350,
		particles_per_length = 35,
		particle_max_lifetime = 300,

		particle_max_initial_velocity = 15,
		particle_velocity_from_cursor = 0.5,
		particle_damping = 0.15,
		particle_gravity = 40,
		min_distance_emit_particles = 0,
	},

	hyper_visor = {
		-- Color y Visibilidad
		gamma = 3,

		-- AJUSTES DE FÍSICA PARA VISIBILIDAD
		particles_enabled = true,
		particles_per_second = 400,
		particle_max_lifetime = 600,
		particle_max_initial_velocity = 15,
		particle_spread = 1.5,
		particle_gravity = -20,
		particle_damping = 0.6,
		-- Prioridad absoluta para legibilidad
		never_draw_over_target = true,
		hide_target_hack = true,

		-- VIBRACIÓN SUAVE
		stiffness = 0.5,
		trailing_stiffness = 0.3,
		damping = 0.6,

		time_interval = 10,
	},
}

-- Aplicamos el perfil seleccionado
local selected_config = profiles[ACTIVE_PROFILE] or profiles.default
smear.setup(selected_config)
