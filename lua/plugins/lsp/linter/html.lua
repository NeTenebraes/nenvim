local lint = require("lint")

-- Usar markuplint en lugar de htmlhint
lint.linters_by_ft.html = { "markuplint" }
