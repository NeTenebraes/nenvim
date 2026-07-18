local ok, noice = pcall(require, "noice")
if not ok then return end

noice.setup({
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
  },

  messages = {
    enabled = true,
    view = "mini",
  },

  lsp = {
    override = {
      ["textDocument/hover"] = true,
      ["textDocument/signatureHelp"] = true,
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },

  presets = {
    bottom_search = false,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = true,
    lsp_doc_border = true,
  },

  views = {
    hover = {
      border = { style = "rounded" },
      win_options = {
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      },
    },

    signature = {
      border = { style = "rounded" },
      win_options = {
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      },
    },

    popupmenu = {
      backend = "cmp",
    },
  },

  routes = {
    {
      filter = {
        event = "notify",
        find = "No information available",
      },
      opts = { skip = true },
    },
    -- Filtrar el progreso de Pyright de forma segura sin romper la UI
    {
      filter = {
        event = "lsp",
        kind = "progress",
        cond = function(message)
          local client_id = message.ctx and message.ctx.client_id
          if not client_id then return false end
          local client = vim.lsp.get_client_by_id(client_id)
          return client and client.name == "pyright"
        end,
      },
      opts = { skip = true },
    },
  },
})

local original_handler = vim.lsp.handlers["$/progress"]
vim.lsp.handlers["$/progress"] = function(err, result, ctx, config)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client and client.name == "pyright" then
    return
  end
  if original_handler then
    original_handler(err, result, ctx, config)
  end
end