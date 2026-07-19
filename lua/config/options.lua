-- =========================================================
-- options.lua
-- Opciones base del editor.
-- Solo comportamiento general; nada de plugins aquí.
-- =========================================================

local opt = vim.opt

-- === UI GENERAL ===
vim.g.netrw_banner = 0 -- Oculta el banner de netrw cuando se use el explorador nativo.
vim.g.loaded_netrw = 1 -- Desactiva netrw para evitar conflictos con otros file explorers.
vim.g.loaded_netrwPlugin = 1 -- Desactiva el plugin de netrw por completo.
vim.opt.timeoutlen = 300

vim.opt.cmdheight = 0

opt.termguicolors = true -- Activa colores 24-bit en la terminal.
opt.number = true -- Muestra números absolutos de línea.
opt.relativenumber = true -- Muestra números relativos para moverte mejor.
opt.cursorline = true -- Resalta la línea actual.
opt.signcolumn = "yes" -- Reserva siempre la columna de signos para diagnósticos/git.
opt.laststatus = 3 -- Barra de estado global para todas las ventanas.
opt.showmode = false -- Oculta el modo actual porque normalmente lo muestra la statusline.
opt.pumblend = 6 -- Suaviza el fondo del menú de autocompletado.
opt.winblend = 6 -- Suaviza transparencias de ventanas flotantes.
opt.background = "dark" -- Fuerza tema oscuro por defecto.
opt.colorcolumn = "100"

-- === NAVEGACIÓN Y VENTANAS ===
opt.mouse = "a" -- Habilita mouse en todos los modos.
opt.splitright = true -- Los splits verticales abren a la derecha.
opt.splitbelow = true -- Los splits horizontales abren abajo.
opt.scrolloff = 8 -- Mantiene 8 líneas visibles arriba y abajo del cursor.
opt.sidescrolloff = 8 -- Mantiene margen horizontal al desplazarte.

-- === EDICIÓN ===
opt.expandtab = true -- Convierte tabs en espacios.
opt.tabstop = 4 -- Un tab visual equivale a 4 espacios.
opt.shiftwidth = 4 -- Indentación automática de 4 espacios.
opt.softtabstop = 4 -- Tab/backspace en inserción usa 4 espacios.
opt.smartindent = true -- Indentación inteligente al abrir bloques.
opt.wrap = false -- No parte las líneas largas.
opt.inccommand = "split" -- Muestra el resultado de sustituciones en una vista aparte.
opt.ignorecase = true -- Búsquedas sin distinguir mayúsculas por defecto.
opt.smartcase = true -- Si la búsqueda tiene mayúsculas, respeta el caso.
opt.isfname:append("@-@") -- Permite que @ y - formen parte de nombres de archivo en motions/completado.

-- === SISTEMA / ARCHIVOS ===
opt.clipboard = "unnamedplus" -- Sincroniza el registro de Neovim con el clipboard del sistema.
opt.swapfile = false -- Desactiva swapfiles.
opt.backup = false -- No genera archivos backup.
opt.undofile = true -- Guarda historial persistente de undo.
opt.undodir = vim.fn.stdpath("data") .. "/undodir" -- Carpeta donde guardar undo persistente.
opt.updatetime = 50 -- Reduce el tiempo de actualización para diagnósticos y eventos.

-- === COMPLETADO / MENSAJES ===
opt.completeopt = { "menuone", "noselect", "fuzzy", "nosort" } -- Menú de completado más usable.
opt.shortmess:append("c") -- Reduce mensajes molestos del completado.

-- === FOLDING / PLEGADO ===
opt.foldmethod = "expr" -- Usa una expresión para calcular plegados.
opt.foldexpr = "v:treesitter#foldexpr()" -- Plegado basado en Treesitter.
opt.foldenable = false -- No abre el archivo plegado al inicio.
opt.foldlevel = 99 -- Deja todos los niveles de plegado abiertos por defecto.
opt.foldcolumn = "0" -- No muestra columna extra para folds.
opt.foldtext = "" -- Usa la línea original como texto del fold.

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Resalta el texto copiado",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 120 })
	end,
})

-- =========================================================
-- CARGA DEL TEMA PERSONALIZADO (Criterio de arquitectura limpia)
-- =========================================================
local status, theme = pcall(require, "themes.dark_cyan.theme01")
if status then
	theme.setup()
else
	vim.notify("Error: No se pudo cargar el theme.lua", vim.log.levels.ERROR)
end

-- =========================================================
-- RESTAURAR ÚLTIMA POSICIÓN DEL CURSOR AL INICIAR
-- =========================================================
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

vim.keymap.set("n", "<leader>I", function()
	vim.cmd("Inspect")
end, { desc = "Inspect nativo" })
