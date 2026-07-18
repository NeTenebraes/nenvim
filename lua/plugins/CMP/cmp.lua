local ok_cmp, cmp = pcall(require, "cmp")
if not ok_cmp then
  return
end

-- Cacheamos LuaSnip arriba una sola vez para rendimiento máximo
local ok_luasnip, luasnip = pcall(require, "luasnip")

cmp.setup({
  performance = {
    max_view_entries = 12,      -- Evita menús gigantescos que tapen el código
    fetching_timeout = 200,     -- Si el LSP tarda, no congela tu escritura
  },

  completion = {
    -- menuone: muestra el menú aunque haya una sola opción
    -- noinsert: no mete texto en el buffer hasta que tú lo elijas
    completeopt = "menu,menuone,noinsert",
  },

  window = {
    completion = cmp.config.window.bordered({
      border = "rounded",
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
      col_offset = -3,
      side_padding = 1,
    }),
    documentation = cmp.config.window.bordered({
      border = "rounded",
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
    }),
  },

  formatting = {
    -- 👑 Estructura Minimalista: [Icono Puro] [Nombre del Código] [Origen]
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
      -- Diccionario nativo de iconos estéticos (Cero dependencias de otros plugins)
      local kind_icons = {
        Text          = "󰉿",
        Method        = "󰆧",
        Function      = "󰊕",
        Constructor   = "",
        Field         = "󰜢",
        Variable      = "󰀫",
        Class         = "󰠱",
        Interface     = "󱤊",
        Module        = "",
        Property      = "󰜢",
        Unit          = "󰑭",
        Value         = "󰎨",
        Enum          = "",
        Keyword       = "󰌋",
        Snippet       = "󰩫", -- Icono limpio para tus Snippets
        Color         = "󰏘",
        File          = "󰈙",
        Reference     = "󰈚",
        Folder        = "󰉋",
        EnumMember    = "",
        Constant      = "󰏿",
        Struct        = "󰙅",
        Event         = "",
        Operator      = "󰆕",
        TypeParameter = "󰅲",
      }

      -- Reemplaza la palabra completa ("Snippet", "Function") por solo su icono con aire a los lados
      vim_item.kind = string.format(" %s ", kind_icons[vim_item.kind] or "")

      -- Etiquetas estéticas y ordenadas para el lado derecho
      local menus = {
        nvim_lsp = "󰅩 LSP",
        path     = "󰉋 Path",
        buffer   = "󰦨 Buf",
        luasnip  = "󰩫 Snip",
      }
      
      vim_item.menu = menus[entry.source.name] or entry.source.name
      
      -- Espaciado óptimo para que el texto central no choque contra la etiqueta derecha
      vim_item.abbr = vim_item.abbr .. "    "
      
      return vim_item
    end,
  },

  snippet = {
    expand = function(args)
      if ok_luasnip then
        luasnip.lsp_expand(args.body)
      end
    end,
  },

  -- 🔌 Fuentes ordenadas de forma inteligente por prioridad de desarrollo
  sources = cmp.config.sources({
    { name = "luasnip", priority = 1000 },  -- Los snippets primero para programar como rayo
    { name = "nvim_lsp", priority = 750 },   -- Autocompletado inteligente de tu lenguaje
    { name = "path",     priority = 500 },   -- Rutas de archivos relativos/absolutos
  }, {
    { name = "buffer",   priority = 250 },   -- Palabras sueltas en tu archivo actual
  }),
})